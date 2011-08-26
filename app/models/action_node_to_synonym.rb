class ActionNodeToSynonym < ActionCommand

  def precondition_do
    @destination_node = Node.find(destination_node_id) rescue nil
    !!(tree_id && node && @destination_node && ancestry_ok?(node) && ancestry_ok?(@destination_node) && !node.has_children?)
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
    merged_node = Node.create!(:tree_id => tree_id, :parent => @destination_node.parent, :name => @destination_node.name, :rank => @destination_node.rank)

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

    self.parent_id = node.parent_id
    new_json_message = JSON.parse(json_message, :symbolize_keys => true)
    self.json_message = new_json_message.merge({ :undo => { :merged_node_id => merged_node.id } }).to_json
    save!
    
    Synonym.create(:node => merged_node, :name => node.name, :status => nil)
    
    @destination_node.children.each do |child|
      child.parent_id = merged_node.id
      child.save!
    end
    
    node.delete_softly

    @destination_node.delete_softly
  end

  def undo_action
    @merged_node.children.each do |child|
      child.parent_id = @destination_node.id
      child.save!
    end
    node.restore(@original_parent)
    @destination_node.restore(@merged_node.parent)
    @merged_node.destroy
    self.json_message = { :do => nil, :undo => nil }.to_json
    save!
  end

  def do_log
    "#{node.name.name_string} made a synonym of #{@destination_node.name.name_string}"
  end

  def undo_log
    "#{node.name.name_string} reverted from being a synonym of #{@destination_node.name.name_string}"
  end

end
