class ActionNodeToLexical < ActionCommand

  def precondition_do
    @destination_node = Node.find(destination_node_id) rescue nil
    !!(tree_id && node && @destination_node && ancestry_ok?(node) && ancestry_ok?(@destination_node) && !node.has_children? && json_message)
  end

  def precondition_undo
    message = JSON.parse(json_message, :symbolize_names => true)
    merged_node_id = message[:undo][:merged_node_id]
    @merged_node = Node.find(merged_node_id) rescue nil
    @original_parent = Node.find(self.parent_id) rescue nil
    @destination_node = Node.find(destination_node_id) rescue nil
    !!(node && @merged_node && @original_parent && @destination_node)
  end

  def do_action
  end

  def undo_action
  end

  def do_log
    "#{node.name.name_string} made a lexical variant of #{@destination_node.name.name_string}"
  end

  def undo_log
    "#{node.name.name_string} reverted from being a lexical variant of #{@destination_node.name.name_string}"
  end

end