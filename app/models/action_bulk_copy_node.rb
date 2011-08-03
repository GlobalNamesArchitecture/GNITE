class ActionBulkCopyNode < ActionCommand

  def precondition_do
    @json_do = JSON.parse(json_message, :symbolize_names => true)[:do]
    @destination_parent = Node.find(destination_parent_id) rescue nil
    !!(tree_id && destination_parent_id && @json_do && @destination_parent)
  end

  def precondition_undo
    @json_undo = JSON.parse(json_message, :symbolize_names => true)[:undo]
    !!(tree_id && @json_undo)
  end

  def do_action
    #TODO add transaction
    node_ids = []
    @json_do.each do |i|
      node = Node.find(i) rescue nil
      copy_node = node.deep_copy_to(@destination_parent.tree)
      copy_node.parent_id = @destination_parent.id
      copy_node.save!
      node_ids << copy_node.id
    end
    self.json_message = {:do => @json_do, :undo => node_ids}.to_json
    save!
  end

  def undo_action
    #TODO add transaction
    @json_undo.each do |i|
      node = Node.find(i) rescue nil
      node.destroy_with_children
    end
  end
  
  def do_log
    destination = (destination_parent_id == @destination_parent.tree.root.id) ? "root" : @destination_parent.name_string
    bulk_copied_names = []
    bulk_copied = JSON.parse(json_message, :symbolize_names => true)[:do]
    bulk_copied.each do |i|
      node = Node.find(i) rescue nil
      bulk_copied_names << node.name_string if node
    end
    node = Node.find(bulk_copied[0]) rescue nil
    reference_tree = node.tree.title if node
    "#{bulk_copied_names.join(", ")} and each of their children (if any) copied to #{destination} from #{reference_tree}"
  end
  
  def undo_log
    bulk_copied_names = []
    bulk_copied = JSON.parse(json_message, :symbolize_names => true)[:do]
    bulk_copied.each do |i|
      node = Node.find(i) rescue nil
      bulk_copied_names << node.name_string if node
    end
    "#{bulk_copied_names.join(", ")} and each of their children (if any) removed"
  end
  
  def nodes
    undo_nodes = @json_do || JSON.parse(json_message, :symbolize_names => true)[:undo] || []
    undo_nodes.map { |i| Node.find(i) rescue nil }.compact
  end

end
