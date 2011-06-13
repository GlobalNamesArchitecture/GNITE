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
  
  def get_log
    "#{self.old_name} renamed to #{self.new_name}"
  end

end

