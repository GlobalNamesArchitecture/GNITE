class ActionRenameNode < ActionCommand

  def precondition_do
    !!node = Node.find(node_id)
  end

  def do_action
    node.rename(new_name)
    self.json_message = node.to_json
    save!
  end

  def undo_action
    node.rename(old_name)
  end

  def undo_title
    title = self.undo? ? "Undo " : "Redo"
    title += "renaming #{self.old_name} to #{self.new_name}"
    title
  end

end

