class ActionNodeToSynonym < ActionCommand

  def precondition_do
    @destination_node = Node.find(destination_node_id) rescue nil
    !!(node && @destination_node && ancestry_ok?(node) && ancestry_ok?(@destination_node) && !node.has_children?)
  end

  def precondition_undo
    true
  end

  def do_action
    merged_node = Node.create!(:tree => master_tree, :parent => @destination_node.parent, :name => @destination_node.name)
    
    new_synonym_names = node.synonyms.map { |s| s.name }
    new_synonym_names = new_synonym_names - @destination_node.synonyms.map { |s| s.name }
    @destination_node.synonyms.each do |synonym|
      Synonym.create!(:node => merged_node, :name => synonym.name, :status => synonym.status)
    end
    new_synonym_names.each do |name|
      Synonym.create!(:node => merged_node, :name => name, :status => nil)
    end
    
    new_vernacular_names = node.vernacular_names.map { |v| v.name }
    new_vernacular_names = new_vernacular_names - @destination_node.vernacular_names.map { |v| v.name }
    @destination_node.vernacular_names.each do |vernacular|
      VernacularName.create!(:node => merged_node, :name => vernacular.name, :language => vernacular.language)
    end
    # TODO: each new_vernacular_names needs :language
    new_vernacular_names.each do |name|
      VernacularName.create!(:node => merged_node, :name => name, :language => nil)
    end
    
    new_json_message = JSON.parse(json_message, :symbolize_keys => true)
    new_json_message.merge({ :undo => { :node_id => merged_node.id } })
    
    self.json_message = new_json_message
    save!
    
    @destination_node.delete_softly
  end

  def undo_action
    merged_node_id = JSON.parse(json_message, :symbolize_names => true)[:undo][:node_id]
    merged_node = Node.find(merged_node_id) rescue nil
    merged_node.destroy
    @destination_node.restore
  end

  def do_log
    "#{node.name} made a synonym of #{@destination_node.name}"
  end

  def undo_log
    "#{node.name} reverted from being a synonym of #{@destination_node.name}"
  end

end
