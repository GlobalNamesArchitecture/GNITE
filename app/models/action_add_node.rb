class ActionAddNode < ActionCommand

  def precondition_do
    !!(tree_id && parent_id && @parent = Node.find(parent_id))
  end

  def precondition_undo
    !!(tree_id && node)
  end

  def do_action
    self.new_name ||= "New child"
    name = Name.find_or_create_by_name_string(new_name)
    node = Node.create!(:parent_id => parent_id, :name => name, :tree => @parent.tree)
    self.node_id = node.id
    self.json_message = node.to_json
    save!
  end

  def undo_action
    node.destroy
    self.node_id = nil
    save!
  end
  
  def get_log
    roots = Node.roots(tree_id)
    parent = Node.find(parent_id)
    destination = (parent_id == roots[0].id) ? "root": parent.name.name_string
    "#{new_name} added under #{destination}"
  end

end

