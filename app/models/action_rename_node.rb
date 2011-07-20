class ActionRenameNode < ActionCommand

  def precondition_do
    node = Node.find(node_id)
    !!(tree_id && node)
  end

  def precondition_undo
    !!tree_id
  end

  def do_action
    node.rename(new_name)
    self.json_message = node.to_json
    save!
  end

  def undo_action
    node.rename(old_name)
  end
  
  def do_log
    "#{old_name} renamed to #{new_name}"
  end
  
  def undo_log
    "#{new_name} reverted to #{old_name}"
  end

end

