class ReferenceTree < Tree
  belongs_to :master_tree

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
end
