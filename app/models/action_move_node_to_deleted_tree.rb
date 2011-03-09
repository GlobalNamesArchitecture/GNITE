class ActionMoveNodeToDeletedTree < ActionCommand

  def precondition_do
    @parent = Node.find(parent_id)
    @node = Node.find(node_id)
    @node && @parent && ancestry_ok?(@parent)
  end

  def do_action
    @node.parent_id = @node.tree.deleted_tree.root.id
    @node.save!
  end

  def undo_action
    @node.parent_id = parent_id
    @node.save!
  end

end
