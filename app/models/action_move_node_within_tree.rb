class ActionMoveNodeWithinTree < ActionCommand
  
  def precondition_do
    @parent = Node.find(parent_id)
    @destination_parent = Node.find(destination_parent_id)
    @node = Node.find(node_id)
    !!(@node && @parent && @destination_parent && ancestry_ok?(@parent) && ancestry_ok?(@destination_parent) && @parent.tree_id == @destination_parent.tree_id)
  end
  
  def do_action
    @node.parent_id = @destination_parent.id
    @node.save!
  end
  
  def undo_action
    @node.parent_id = @parent.id
    @node.save!
  end
  
end
