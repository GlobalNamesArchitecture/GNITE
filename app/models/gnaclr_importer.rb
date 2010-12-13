# encoding: utf-8
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
    begin
      fetch_tarball
      read_tarball
      store_tree
      activate_tree
    rescue RuntimeError => e
      DarwinCore.logger_write(@dwc.object_id, "Import Failed: %s" % e)
    end
  end

  def fetch_tarball
    if url.match(/^\s*http:\/\//)
      dlr = Gnite::Downloader.new(url, tarball_path)
      downloaded_length = dlr.download_with_percentage do |r|
        msg = sprintf("Downloaded %.0f%% in %.0f seconds ETA is %.0f seconds", r[:percentage], r[:elapsed_time], r[:eta])
        GnaclrImporterLog.create(:reference_tree_id => self.reference_tree_id, :message => msg)
      end
      GnaclrImporterLog.create(:reference_tree_id => self.reference_tree_id, :message => "Download finished, Size: %s" % downloaded_length)
    else
      Kernel.system("curl -s #{url} > #{tarball_path}")
    end
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
    DarwinCore.logger_write(@dwc.object_id, "Populating local database")
    DarwinCore.logger_write(@dwc.object_id, "Processing name strings")
    count = 0
    name_strings.in_groups_of(NAME_BATCH_SIZE).each do |group|
      count += NAME_BATCH_SIZE
      group = group.compact.collect do |name_string|
        Name.connection.quote(name_string).force_encoding('utf-8')
      end.join('), (')

      Name.transaction do
        Name.connection.execute "INSERT IGNORE INTO names (name_string) VALUES (#{group})"
      end
      DarwinCore.logger_write(@dwc.object_id, "Traversed %s scientific name strings" % count)
    end
    @nodes_count = 0
    build_tree(tree)
    DarwinCore.logger_write(@dwc.object_id, "Adding synonyms and vernacular names")
    insert_synonyms_and_vernacular_names
  end

  def build_tree(root, parent_id = nil)
    taxon_ids = root.keys
    taxon_ids.each do |taxon_id|
      @nodes_count += 1
      DarwinCore.logger_write(@dwc.object_id, "Inserting %s record into database" % @nodes_count) if @nodes_count % 10000 == 0
      next unless taxon_id && darwin_core_data[taxon_id]

      local_id_sql   = Name.connection.quote(taxon_id).force_encoding('utf-8')
      name_sql       = Name.connection.quote(darwin_core_data[taxon_id].current_name).force_encoding('utf-8')
      rank_sql       = Node.connection.quote(darwin_core_data[taxon_id].rank).force_encoding('utf-8')
      parent_id ||= 'NULL'

      node_id = Node.connection.insert("INSERT IGNORE INTO nodes (local_id, name_id, tree_id, parent_id, rank) \
                    VALUES (#{local_id_sql}, (SELECT id FROM names WHERE name_string = #{name_sql} LIMIT 1), \
                                       #{reference_tree.id}, #{parent_id}, #{rank_sql})")
      add_synonyms_and_vernacular_names(node_id, taxon_id)
      build_tree(root[taxon_id], node_id)
    end
  end

  def activate_tree
    ReferenceTree.update_all 'state = "active"', "id = #{reference_tree.id}"
    DarwinCore.logger_write(@dwc.object_id, "Import is successful")
  end

  private

  def add_synonyms_and_vernacular_names(node_id, taxon_id)
    (@synonyms ||= []) << [node_id, darwin_core_data[taxon_id].synonyms]
    (@vernacular_names ||= []) << [node_id, darwin_core_data[taxon_id].vernacular_names]
  end

  def insert_synonyms_and_vernacular_names
    count = 0
    { 'synonyms'         => @synonyms,
      'vernacular_names' => @vernacular_names }.each do |table, alternate_names|
      alternate_names.each do |node_id, names|
        names.map(&:name).each do |name_string|
          count += 1
          DarwinCore.logger_write(@dwc.object_id, "Added %s synonyms and vernacular names" % count) if count % 10000 == 0
          name_sql = Name.connection.quote(name_string)

          Name.connection.execute "INSERT IGNORE INTO #{table} (node_id, name_id) VALUES (#{node_id.to_i}, (SELECT id FROM names WHERE name_string = #{name_sql} LIMIT 1))"
        end
      end
      end
  end
  
  #TODO not used anymore?
  # def copy_nodes_from_prior_import
  #   now = Time.now
  #   prior_tree = ReferenceTree.where(['source_id = ?', reference_tree.source_id]).order('created_at asc').first
  #   nodes = prior_tree.nodes
  #   unless nodes.empty?
  #     nodes_sql = nodes.
  #       map { |node| "(#{reference_tree.id}, #{Node.connection.quote(node.ancestry)}, \\
  #         #{node.name_id}, #{Node.connection.quote(node.rank)}, \\
  #         #{Node.connection.quote(now.to_s(:db))}, #{Node.connection.quote(now.to_s(:db))})" }.
  #         join(',')
  #     sql = "INSERT IGNORE INTO nodes (tree_id, ancestry, name_id, rank, created_at, updated_at) VALUES #{nodes_sql}"
  #     Node.connection.execute(sql)
  #   end
  # end

  def tarball_path
    Rails.root.join('tmp', reference_tree.id.to_s).to_s
  end
end
