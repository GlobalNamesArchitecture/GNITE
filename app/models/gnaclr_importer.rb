class GnaclrImporter < ActiveRecord::Base
  belongs_to :reference_tree

  unless defined? GNACLR_IMPORTER_DEFINED
    NAME_BATCH_SIZE = 10_000
    GNACLR_IMPORTER_DEFINED = true
  end
  @queue = :gnaclr_importer

  attr_reader   :darwin_core_data, :name_strings, :tree

  def self.perform(gnaclr_importer_id)
    gi = GnaclrImporter.find(gnaclr_importer_id)
    gi.import
  end

  def import
    fetch_tarball
    read_tarball
    store_tree
    activate_tree
  end

  def fetch_tarball
    Kernel.system("curl -s #{url} > #{tarball_path}")
  end

  def read_tarball
    @dwc               = DarwinCore.new(tarball_path)
    DarwinCore.logger.subscribe(:dwc_object_id => @dwc.object_id, :reference_tree_id => self.reference_tree_id)
    normalizer        = DarwinCore::ClassificationNormalizer.new(@dwc)
    @darwin_core_data = normalizer.normalize
    @tree             = normalizer.tree
    @name_strings     = normalizer.name_strings
  end

  def store_tree
    name_strings.in_groups_of(NAME_BATCH_SIZE).each do |group|
      group = group.compact.collect do |name_string|
        Name.connection.quote(name_string)
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

      local_id_sql   = Name.connection.quote(taxon_id)
      name_sql       = Name.connection.quote(darwin_core_data[taxon_id].current_name)
      rank_sql       = Node.connection.quote(darwin_core_data[taxon_id].rank)
      ancestry_sql   = Node.connection.quote(ancestry) if ancestry.present?
      ancestry_sql ||= 'NULL'

      node_id = Node.connection.insert("INSERT INTO nodes (local_id, name_id, tree_id, ancestry, rank) \
                    VALUES (#{local_id_sql}, (SELECT id FROM names WHERE name_string = #{name_sql} LIMIT 1), \
                                       #{reference_tree.id}, #{ancestry_sql}, #{rank_sql})")

      next_ancestry = ancestry ? ancestry.dup : ''
      next_ancestry << '/' unless next_ancestry.empty?
      next_ancestry << node_id.to_s

      add_synonyms_and_vernacular_names(node_id, taxon_id)
      build_tree(root[taxon_id], next_ancestry)
    end
  end

  def activate_tree
    ReferenceTree.update_all 'state = "active"', "id = #{reference_tree.id}"
  end

  private

  def add_synonyms_and_vernacular_names(node_id, taxon_id)
    (@synonyms ||= []) << [node_id, darwin_core_data[taxon_id].synonyms]
    (@vernacular_names ||= []) << [node_id, darwin_core_data[taxon_id].vernacular_names]
  end

  def insert_synonyms_and_vernacular_names
    (@synonyms + @vernacular_names).collect do |node_id, names|
      names.map(&:name)
    end.flatten.in_groups_of(NAME_BATCH_SIZE).each do |group|
      group = group.compact.collect do |name_string|
        Name.connection.quote(name_string)
      end.join('), (')

      Name.transaction do
        Name.connection.execute "INSERT IGNORE INTO names (name_string) VALUES (#{group})"
      end
    end

    { 'synonyms'         => @synonyms,
      'vernacular_names' => @vernacular_names }.each do |table, alternate_names|
      alternate_names.each do |node_id, names|
        names.map(&:name).each do |name_string|
          name_sql = Name.connection.quote(name_string)

          Name.connection.execute "INSERT INTO #{table} (node_id, name_id) VALUES (#{node_id.to_i}, (SELECT id FROM names WHERE name_string = #{name_sql} LIMIT 1))"
        end
      end
      end
  end
  
  # TODO: not used, either delete or use it right
  # def tree_already_imported?
  #   return false unless reference_tree.source_id
  #   ReferenceTree.count(['source_id = ? and state = ?',
  #                       reference_tree.source_id,
  #                       'active']) > 1
  # end

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

  def tarball_path
    Rails.root.join('tmp', reference_tree.id.to_s).to_s
  end
end
