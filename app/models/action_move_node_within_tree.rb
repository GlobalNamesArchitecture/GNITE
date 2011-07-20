class ActionMoveNodeWithinTree < ActionCommand

  def precondition_do
    @parent = Node.find(parent_id)
    @destination_parent = Node.find(destination_parent_id)
    !!(tree_id \
       && node && @parent && @destination_parent \
       && ancestry_ok?(@parent) \
       && ancestry_ok?(@destination_parent) \
       && @parent.tree_id == @destination_parent.tree_id)
  end

  def do_action
    node.parent_id = @destination_parent.id
    node.save!
    self.json_message = node.to_json
    save!
  end

  def undo_action
    node.parent_id = @parent.id
    node.save!
  end
  
  def do_log
    "#{node.name_string} moved from #{@parent.name_string} to #{@destination_parent.name_string}"
  end
  
  def undo_log
    "#{node.name_string} reverted from #{@destination_parent.name_string} to #{@parent.name_string}"
  end

end
