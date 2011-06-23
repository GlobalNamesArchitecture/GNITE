class ActionBulkAddNode < ActionCommand

  def precondition_do
    @json_do = JSON.parse(json_message, :symbolize_names => true)[:do]
    !!(tree_id && parent_id && @json_do && @parent = Node.find(parent_id))
  end

  def precondition_undo
    @json_undo = JSON.parse(json_message, :symbolize_names => true)[:undo]
    !!(tree_id && @json_undo)
  end

  def do_action
    node_ids = []
    @json_do.each do |new_name|
      name = Name.find_or_create_by_name_string(new_name)
      node = Node.create!(:parent_id => parent_id, :name => name, :tree => @parent.tree)
      node_ids << node.id
    end
    self.json_message = {:do => @json_do, :undo => node_ids}.to_json
    save!
  end

  def undo_action
    @json_undo.each do |i|
      node = Node.find(i) rescue nil
      node.destroy if node
    end
  end
  
  def generate_log
    roots = Node.roots(tree_id)
    parent = Node.find(parent_id)
    destination = (parent_id == roots[0].id) ? "root": parent.name.name_string
    bulk_added = JSON.parse(json_message, :symbolize_names => true)[:do].join(", ")
    "#{bulk_added} added under #{destination}"
  end

  def nodes
    undo_nodes = @json_undo || JSON.parse(json_message, :symbolize_names => true)[:undo] || []
    undo_nodes.map { |i| Node.find(i) rescue nil }.compact
  end

end
