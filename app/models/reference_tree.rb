class ReferenceTree < Tree
  has_many :gnaclr_importers
  has_many :reference_tree_collections
  has_many :master_trees, :through => :reference_tree_collections

  after_create :create_collection

  def self.create_from_list(tree_params, node_list)
    tree = ReferenceTree.new(tree_params)
    tree.save
    node_list.each do |node_name|
      name = Name.find_or_create_by_name_string(node_name)
      n = Node.new(:tree => tree, :name => name)
      n.save
    end
    tree
  end

  private

  def create_collection
    return unless self.master_tree_id
    ReferenceTreeCollection.create!(:reference_tree => self, :master_tree_id => self.master_tree_id) ##TODO: HACK warning!!!
    self.master_tree_id = nil
    self.save!
  end
end
