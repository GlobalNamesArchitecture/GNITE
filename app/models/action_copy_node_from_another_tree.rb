class ActionCopyNodeFromAnotherTree < ActionCommand

  def precondition_do
    @destination_node = Node.find(destination_parent_id) rescue nil
    !!(tree_id && node && @destination_node && ancestry_ok?(@destination_node))
  end

  def precondition_undo
    @destination_node = Node.find(destination_node_id) rescue nil
    !!(tree_id && @destination_node)
  end

  def do_action
    #TODO add transaction
    copy_node = node.deep_copy_to(@destination_node.tree)
    copy_node.parent_id = @destination_node.id
    copy_node.save!
    self.destination_node_id = copy_node.id
    self.json_message = copy_node.to_json
    self.save!
  end

  def undo_action
    @destination_node.destroy_with_children
  end
  
  def do_log
    destination = (destination_parent_id == @destination_node.tree.root.id) ? "root": @destination_node.name_string
    reference_tree = node.tree.title
    "#{node.name_string} and its children (if any) copied to #{destination} from #{reference_tree}"
  end
  
  def undo_log
    "#{old_name} and its children (if any) removed"
  end

  def master_tree
    begin
      Node.find(destination_parent_id).tree
    rescue NoMethodError
      nil
    end
  end

end
