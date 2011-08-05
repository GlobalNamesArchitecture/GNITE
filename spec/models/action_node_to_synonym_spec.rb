require 'spec_helper'

describe ActionNodeToSynonym do
  subject { Factory(:action_node_to_synonym) }

  before(:all) do
    ["Synonym one", "Synonym two", "Synonym three", "Synonym four", "Vern1", "Vern2", "Vern3", "Vern4", "Vern6"].each { |n| Factory(:name, :name_string => n) }
    ["Synonym one", "Synonym two", "Synonym three"].each { |n| Factory(:synonym, :node => Node.find(subject.node_id), :name => Name.find_by_name_string(n)) }
    ["Vern1", "Vern2", "Vern3"].each { |n| Factory(:vernacular_name, :node => Node.find(subject.node_id), :name => Name.find_by_name_string(n)) }
    ["Synonym one", "Synonym four"].each { |n| Factory(:synonym, :node => Node.find(subject.destination_node_id), :name => Name.find_by_name_string(n)) }
    ["Vern4", "Vern2", "Vern6"].each { |n| Factory(:vernacular_name, :node => Node.find(subject.destination_node_id), :name => Name.find_by_name_string(n)) }
  end

  it 'should return master tree' do
    subject.master_tree.should == Node.find(subject.node_id).tree
  end
 
  it 'should create a node with merged metadata' do
    JSON.parse(subject.json_message, :symbolize_keys => true)[:undo].should be_nil
    ActionNodeToSynonym.perform(subject.id)
    subject.reload.undo?.should be_true
    undo_info = JSON.parse(subject.reload.json_message, :symbolize_keys => true)[:undo]
    undo_info.should_not be_nil
    merged_node = Node.find(undo_info[:merged_node_id])
    merged_node.name_string.should == Node.find(subject.destination_node_id).name_string
    merged_node.rank == Node.find(subject.destination_node_id).rank
    merged_node.synonyms.map {|s| s.name_string}.include?(subject.node.name_string)
    merged_node.synonyms.size.should == 5
    merged_node.vernacular_names.size.should == 5
    subject.undo?.should be_true
  end

  it 'should not move node to synonyms if precondition "node has kids" is not met' do
    ans = Factory(:action_node_to_synonym)
    Factory(:node, :parent_id => ans.node_id)
    expect{ ActionNodeToSynonym.perform(ans.id) }.to raise_error
  end
  
  it 'should not move node to synonyms if precondition "node exists" is not met' do
    ans = Factory(:action_node_to_synonym)
    Node.find(ans.node_id).destroy
    expect{ ActionNodeToSynonym.perform(ans.id) }.to raise_error
  end

  it 'should not move node to synonyms if precondition "destination node exists" is not met' do
    ans = Factory(:action_node_to_synonym)
    Node.find(ans.destination_node_id).destroy
    expect{ ActionNodeToSynonym.perform(ans.id) }.to raise_error
  end
  
  it 'should not restore node from synonyms if precondition "undo message" is not met' do
    ans = Factory(:action_node_to_synonym)
    ActionNodeToSynonym.perform(ans.id)
    ans.json_message = nil
    ans.save!
    expect{ ActionNodeToSynonym.perform(ans.id) }.to raise_error
  end
  
  it 'should not restore node from synonyms if precondition "new node" is not met' do
    ans = Factory(:action_node_to_synonym)
    ActionNodeToSynonym.perform(ans.id)
    ans.reload.undo?.should be_true
    message = JSON.parse(ans.json_message, :symbolize_names => true)
    Node.find(message[:undo][:merged_node_id]).is_a?(::Node).should be_true
    Node.find(message[:undo][:merged_node_id]).destroy
    expect{ ActionNodeToSynonym.perform(ans.id) }.to raise_error
  end
  
  it 'should not restore node from synonyms if precondition "old destination node" is not met' do
    ActionNodeToSynonym.perform(subject.id)
    subject.reload.undo?.should be_true
    Node.find(subject.destination_node_id).destroy
    expect{ ActionNodeToSynonym.perform(subject.id) }.to raise_error
  end
  
  it 'should not restore node from synonyms if precondition "original node" is not met' do
    ans = Factory(:action_node_to_synonym)
    ActionNodeToSynonym.perform(ans.id)
    ans.reload.undo?.should be_true
    Node.find(ans.node_id).is_a?(::Node).should be_true
    Node.find(ans.node_id).destroy
    expect{ ActionNodeToSynonym.perform(ans.id) }.to raise_error
  end
  
  it 'should not restore node from synonyms if precondition "original node parent" is not met' do
    ans = Factory(:action_node_to_synonym)
    ActionNodeToSynonym.perform(ans.id)
    ans.reload.undo?.should be_true
    message = JSON.parse(ans.json_message, :symbolize_names => true)
    Node.find(message[:do][:original_parent_id]).is_a?(::Node).should be_true
    Node.find(message[:do][:original_parent_id]).destroy
    expect{ ActionNodeToSynonym.perform(ans.id) }.to raise_error
  end
  
end
