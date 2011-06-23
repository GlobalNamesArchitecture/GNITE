class ActionCopyNodeFromAnotherTree < ActionCommand

  def precondition_do
    @destination_parent = Node.find(destination_parent_id)
    !!(tree_id && node && @destination_parent && ancestry_ok?(@destination_parent))
  end

  def precondition_undo
    @destination_node = Node.find(destination_node_id)
    !!(tree_id && @destination_node)
  end

  def do_action
    copy_node = node.deep_copy_to(@destination_parent.tree)
    copy_node.parent_id = @destination_parent.id
    copy_node.save!
    self.destination_node_id = copy_node.id
    self.json_message = copy_node.to_json
    self.save!
  end

  def undo_action
    @destination_node.destroy_with_children
  end
  
  def generate_log
    tree = Tree.find(tree_id)
    destination = Node.find(destination_parent_id)
    "#{node.name.name_string} and its children (if any) copied to #{destination.name.name_string} from #{tree.title}"
  end

  def master_tree
    begin
      Node.find(destination_parent_id).tree
    rescue NoMethodError
      nil
    end
  end

end
