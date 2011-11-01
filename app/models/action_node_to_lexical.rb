class ActionNodeToLexical < ActionCommand

  def precondition_do
    @destination_node = Node.find(destination_node_id) rescue nil
    !!(tree_id && node && @destination_node && ancestry_ok?(node) && ancestry_ok?(@destination_node) && !node.has_children? && json_message)
  end

  def precondition_undo
    message = JSON.parse(json_message, :symbolize_names => true)
    lexicalable_id = message[:undo][:lexicalable_id]
    @lexical = LexicalVariant.find(lexicalable_id) rescue nil
    @destination_node = Node.find(destination_node_id) rescue nil
    @original_parent = Node.find(self.parent_id) rescue nil
    !!(node && @lexical && @original_parent && @destination_node)
  end

  def do_action
    lexical_variant = LexicalVariant.create!(:lexicalable => @destination_node, :name => node.name)
    new_json_message = JSON.parse(json_message, :symbolize_keys => true)
    self.json_message = new_json_message.merge({ :undo => { :lexicalable_id => lexical_variant.id } }).to_json
    save!
    node.delete_softly
  end

  def undo_action
    @lexical.destroy
    node.restore(@original_parent)
    self.json_message = { :do => nil, :undo => nil }.to_json
    save!
  end

  def do_log
    "#{node.name.name_string} made a lexical variant of #{@destination_node.name.name_string}"
  end

  def undo_log
    "#{node.name.name_string} reverted from being a lexical variant of #{@destination_node.name.name_string}"
  end

end