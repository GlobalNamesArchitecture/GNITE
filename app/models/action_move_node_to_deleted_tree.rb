class ActionMoveNodeToDeletedTree < ActionCommand

  def precondition_do
    @parent = Node.find(parent_id) rescue nil
    !!(tree_id && node && @parent && ancestry_ok?(@parent))
  end

  def do_action
    node.delete_softly
    self.json_message = node.to_json
    save!
  end

  def undo_action
    node.restore(@parent)
  end
  
  def do_log
    "#{node.name_string} and its children (if any) deleted"
  end
  
  def undo_log
    "#{node.name_string} and its children (if any) restored"
  end

end
