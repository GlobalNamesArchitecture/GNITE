class ActionBulkCopyNode < ActionCommand

  def precondition_do
    @destination_parent = Node.find(destination_parent_id)
    @json_do = JSON.parse(json_message, :symbolize_names => true)[:do]
    !!(tree_id && parent_id && @json_do && @parent = Node.find(parent_id) && @destination_parent && ancestry_ok?(@destination_parent))
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
      node_ids << node.id
    end
    self.json_message = {:do => @json_do, :undo => node_ids}.to_json
    save!
  end

  def undo_action
    @json_undo.each do |i|
      node = Node.find(i) rescue nil
      node.destroy_with_children
    end
  end
  
  def generate_log
    reference_tree = Tree.find(node.tree).title   
    parent = Node.find(parent_id)
    destination = (parent_id == parent.tree.root.id) ? "root": parent.name_string
    bulk_copied_names = []
    bulk_copied = JSON.parse(json_message, :symbolize_names => true)[:do]
    bulk_copied.each do |i|
      bulk_copied_names << Node.find(i).name
    end
    bulk_copied_names.join(", ")

    "#{bulk_copied_names} and each of their children (if any) copied to #{destination} from #{reference_tree}"
  end

  def nodes
    undo_nodes = @json_undo || JSON.parse(json_message, :symbolize_names => true)[:undo] || []
    undo_nodes.map { |i| Node.find(i) rescue nil }.compact
  end

end
