class ActionNodeToSynonym < ActionCommand

  def precondition_do
    @destination_node = Node.find(destination_node_id) rescue nil
    !!(node && @destination_node && node.ancestry_ok? && @destination_node.ancestry_ok? && !node.has_children?)
  end

  def precondition_undo
    true
  end

  def do_action
    new_synonym_names = node.synonyms.map { |s| s.name }
    new_synonym_names = new_synonym_names - @destination_node.synonyms.map { |s| s.name }
    merged_node = Node.create!(:tree => master_tree, :parent => @destination_node.parent, :name => @destination_node.name)
    @destination_node.synonyms.each do |synonym|
      Synonym.create!(:node => merged_node, :name => synonym.name, :status => synonym.status)
    end

    new_synonyms.each do |name|
      Synonym.create!(:node => merged_node, :name => name, :status => nil)
    end
    new_json_message = JSON.parse(json_message, :symbolize_keys => true)
    new_json_message.merge({ :undo => { :node_id => merged_node.id } })
    #node.parent_id = 
  end

  def undo_action
  end

  def do_log
  end

  def undo_log
  end

end
