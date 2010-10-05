class GnaclrImporter
  NAME_BATCH_SIZE = 10_000.freeze

  attr_reader   :darwin_core_data, :name_strings, :tree
  attr_accessor :reference_tree, :url

  def initialize(opts)
    @reference_tree = opts[:reference_tree]
    @url            = opts[:url]
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

      Name.transaction do
        Name.connection.execute "INSERT IGNORE INTO names (name_string) VALUES (#{group})"
      end
    end

    build_tree(tree)
    insert_synonyms_and_vernacular_names
  end

  def build_tree(root, ancestry = nil)
    taxon_ids = root.keys
    taxon_ids.each do |taxon_id|
      next unless taxon_id && darwin_core_data[taxon_id]

      name_sql       = Name.__send__(:quote_bound_value, darwin_core_data[taxon_id].current_name)
      rank_sql       = Node.__send__(:quote_bound_value, darwin_core_data[taxon_id].rank)
      ancestry_sql   = Node.__send__(:quote_bound_value, ancestry) if ancestry.present?
      ancestry_sql ||= 'NULL'

      node_id = Node.connection.insert("INSERT INTO nodes (name_id, tree_id, ancestry, rank) VALUES ((SELECT id FROM names WHERE name_string = #{name_sql} LIMIT 1), #{reference_tree.id}, #{ancestry_sql}, #{rank_sql})")

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
    ReferenceTree.update_all 'state = "active"', "id = #{reference_tree.id}"
  end

  def perform
    if tree_already_imported?
      copy_nodes_from_prior_import
    else
      fetch_tarball
      read_tarball
      store_tree
    end
    activate_tree
  end

  def tree_already_imported?
    ReferenceTree.count(['source_id = ? and state = ?',
                        reference_tree.source_id,
                        'active']) > 1
  end
  private :tree_already_imported?

  def copy_nodes_from_prior_import
    now = Time.now
    prior_tree = ReferenceTree.where(['source_id = ?', reference_tree.source_id]).order('created_at asc').first
    nodes = prior_tree.nodes
    unless nodes.empty?
      nodes_sql = nodes.
        map { |node| "(#{reference_tree.id}, #{Node.connection.quote(node.ancestry)}, \
          #{node.name_id}, #{Node.connection.quote(node.rank)}, \
          #{Node.connection.quote(now.to_s(:db))}, #{Node.connection.quote(now.to_s(:db))})" }.
        join(',')
      sql = "INSERT INTO nodes (tree_id, ancestry, name_id, rank, created_at, updated_at) VALUES #{nodes_sql}"
      Node.connection.execute(sql)
    end
  end
  private :copy_nodes_from_prior_import

  def copy_existing_tree(uuid)
    ref_tree = ReferenceTree.find_by_uuid!(uuid)
    # copy tree to new master tree
    # copy nodes
  end
  private :copy_existing_tree

  def enqueue
    Delayed::Job.enqueue(self)
  end
  private :enqueue

  def tarball_path
    Rails.root.join('tmp', reference_tree.id.to_s).to_s
  end
  private :tarball_path
end
