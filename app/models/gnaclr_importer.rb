class GnaclrImporter
  attr_reader   :darwin_core_data
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
    @darwin_core_data = DarwinCore::ClassificationNormalizer.new(dwc).normalize
  end

  def store_tree
    id_hash = {}
    darwin_core_data.each do |taxon_id, taxon_normalized|
      name = Name.find_or_create_by_name_string(taxon_normalized.current_name)
      node = Node.create!(:name    => name,
                          :tree_id => reference_tree_id)
      id_hash[taxon_normalized.id] = node.id
    end
    id_hash.each do |taxon_id, node_id|
      if parent_id = id_hash[darwin_core_data[taxon_id].parent_id]
        node           = Node.find(node_id)
        node.parent_id = parent_id
        node.save
      end
    end
  end

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
