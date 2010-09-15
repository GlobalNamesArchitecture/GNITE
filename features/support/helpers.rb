module NodeFinders
  def first_node_by_name(name_string)
    name = Name.find_by_name_string(name_string)
    name.nodes.first
  end

  def first_node_by_name_for_tree(name_string, tree)
    name = Name.find_by_name_string(name_string)
    name.nodes.where(:tree => tree).first
  end
end

World(NodeFinders)
