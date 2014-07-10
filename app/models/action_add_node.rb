class ActionAddNode < ActionCommand

  def precondition_do
    @parent = Node.find(parent_id) rescue nil
    !!(tree_id && parent_id && @parent)
  end

  def precondition_undo
    !!(tree_id && node)
  end

  def do_action
    self.new_name ||= "New child"
    name = Name.find_or_create_by_name_string(new_name)
    node = Node.create!(parent_id: parent_id, name: name, tree: @parent.tree)
    self.node_id = node.id
    self.json_message = node.to_json
    save!
  end

  def undo_action
    node.destroy
    self.node_id = nil
    save!
  end
  
  def do_log
    destination = (parent_id == @parent.tree.root.id) ? "root": @parent.name_string
    "#{new_name} added under #{destination}"
  end
  
  def undo_log
    "#{new_name} removed"
  end

end

