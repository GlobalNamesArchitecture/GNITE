class ActionMoveNodeToDeletedTree < ActionCommand

  def precondition_do
    @parent = Node.find(parent_id)
    node && @parent && ancestry_ok?(@parent)
  end

  def do_action
    node.parent_id = node.tree.deleted_tree.root.id
    node.tree_id = node.tree.deleted_tree.id
    node.save!
    node.descendants.each do |descendant|
      descendant.tree_id = node.tree.deleted_tree.id
      descendant.save!
    end
    self.json_message = node.to_json
    save!
  end

  def undo_action
    node.parent_id = parent_id
    node.tree_id = @parent.tree.id
    node.save!
    node.descendants.each do |descendant|
      descendant.tree_id = @parent.tree.id
      descendant.save!
    end
  end

  def master_tree
    node.tree.is_a?(DeletedTree) ? node.tree.master_tree : super
  end

end
