class GnaclrImporter
  NAME_BATCH_SIZE = 10_000.freeze

  attr_reader   :darwin_core_data, :name_strings, :tree
  attr_accessor :reference_tree_id, :url

  def initialize(opts)
    @reference_tree_id = opts[:reference_tree_id].to_i
    @url               = opts[:url]
    enqueue
  end

  def fetch_tarball
    Kernel.system("curl -s #{url} > #{tarball_path}")
  end

  def read_tarball
    dwc               = DarwinCore.new(tarball_path)
    normalizer        = DarwinCore::ClassificationNormalizer.new(dwc)
    @darwin_core_data = normalizer.normalize
    @tree             = normalizer.tree
    @name_strings     = normalizer.name_strings
  end

  def store_tree
    name_strings.in_groups_of(NAME_BATCH_SIZE).each do |group|
      group = group.compact.collect do |name_string|
        Name.__send__(:quote_bound_value, name_string)
      end.join('), (')

      Name.connection.execute "BEGIN"
      Name.connection.execute "INSERT IGNORE INTO names (name_string) VALUES (#{group})"
      Name.connection.execute "COMMIT"
    end

    build_tree(tree)
    insert_synonyms_and_vernacular_names
  end

  def build_tree(root, ancestry = nil)
    taxon_ids = root.keys
    taxon_ids.each do |taxon_id|
      next unless taxon_id && darwin_core_data[taxon_id]

      name_sql       = Name.__send__(:quote_bound_value, darwin_core_data[taxon_id].current_name)
      ancestry_sql   = Node.__send__(:quote_bound_value, ancestry) if ancestry.present?
      ancestry_sql ||= 'NULL'

      node_id = Node.connection.insert("INSERT INTO nodes (name_id, tree_id, ancestry) VALUES ((SELECT id FROM names WHERE name_string = #{name_sql} LIMIT 1), #{reference_tree_id}, #{ancestry_sql})")

      next_ancestry = ancestry ? ancestry.dup : ''
      next_ancestry << '/' unless next_ancestry.empty?
      next_ancestry << node_id.to_s

      add_synonyms_and_vernacular_names(node_id, taxon_id)
      build_tree(root[taxon_id], next_ancestry)
    end
  end

  def add_synonyms_and_vernacular_names(node_id, taxon_id)
    (@synonyms ||= []) << [node_id, darwin_core_data[taxon_id].synonyms]
    (@vernacular_names ||= []) << [node_id, darwin_core_data[taxon_id].vernacular_names]
  end
  private :add_synonyms_and_vernacular_names

  def insert_synonyms_and_vernacular_names
    (@synonyms + @vernacular_names).collect do |node_id, names|
      names.map(&:name)
    end.flatten.in_groups_of(NAME_BATCH_SIZE).each do |group|
      group = group.compact.collect do |name_string|
        Name.__send__(:quote_bound_value, name_string)
      end.join('), (')
      Name.connection.execute "BEGIN"
      Name.connection.execute "INSERT IGNORE INTO names (name_string) VALUES (#{group})"
      Name.connection.execute "COMMIT"
    end

    { 'synonyms'         => @synonyms,
      'vernacular_names' => @vernacular_names }.each do |table, alternate_names|
      alternate_names.each do |node_id, names|
        names.map(&:name).each do |name_string|
          name_sql = Name.__send__(:quote_bound_value, name_string)

          Name.connection.execute "INSERT INTO #{table} (node_id, name_id) VALUES (#{node_id.to_i}, (SELECT id FROM names WHERE name_string = #{name_sql} LIMIT 1))"
        end
      end
    end
  end
  private :insert_synonyms_and_vernacular_names

  def activate_tree
    ReferenceTree.update_all 'state = "active"', "id = #{reference_tree_id}"
  end

  def perform
    fetch_tarball
    read_tarball
    store_tree
    activate_tree
  end

  def enqueue
    Delayed::Job.enqueue(self)
  end
  private :enqueue

  def tarball_path
    Rails.root.join('tmp', reference_tree_id.to_s).to_s
  end
  private :tarball_path
end
