class ReferenceTree < Tree
  has_many :gnaclr_importers
  has_many :reference_tree_collections
  has_many :master_trees, through: :reference_tree_collections

  validates_presence_of :revision
  validates_presence_of :publication_date

  def self.create_from_list(tree_params, node_list)
    tree_params.permit! if tree_params.respond_to?(:permit!)
    tree = ReferenceTree.new(tree_params)
    tree.save
    node_list.each do |node_name|
      name = Name.find_or_create_by(name_string: node_name)
      n = Node.new(tree: tree, name: name)
      n.save
    end
    tree
  end
  
  def nuke
    Tree.connection.execute("DELETE FROM reference_tree_collections WHERE reference_tree_id = #{id}")
    super
  end

end
