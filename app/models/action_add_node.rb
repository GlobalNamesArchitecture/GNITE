class ActionAddNode < ActionCommand

  def precondition_do
    !!(parent_id && @parent = Node.find(parent_id))
  end

  def precondition_undo
    !!node
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

  def master_tree
    begin
      Node.find(parent_id).tree
    rescue NoMethodError
      nil
    end
  end

end

