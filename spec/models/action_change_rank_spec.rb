require 'spec_helper'

describe ActionChangeRank do
  subject { Factory(:action_change_rank) }

  it 'should return node' do
    subject.node.should == Node.find(subject.node_id)
  end

  it 'should return master_tree' do
    subject.master_tree.should == subject.node.tree
  end

  it 'should change the rank on first perform and get the old rank on second perform' do
    node = Node.find(subject.node_id)
    old_node_rank = node.rank
    ActionChangeRank.perform(subject.id)
    subject.reload.undo?.should be_true
    json_message = JSON.parse(subject.reload.json_message, :symbolize_names => true)
    json_message[:undo].should == old_node_rank
    node.reload.rank.should == json_message[:do]
    ActionChangeRank.perform(subject.id)
    node.reload.rank.should == json_message[:undo]
  end

  it 'should not change rank if preconditions are not met' do
    acr = Factory(:action_change_rank)
    Node.find(acr.node_id).destroy
    expect{ ActionChangeRank.perform(acr.id) }.to raise_error
    acr = Factory(:action_change_rank)
    acr.json_message = nil
    acr.save!
    expect{ ActionChangeRank.perform(acr.id) }.to raise_error
  end

  it 'should not undo change rank if precondition is not met' do
    acr = Factory(:action_change_rank)
    acr.json_message = nil
    acr.save!
    expect{ ActionChangeRank.perform(acr.id) }.to raise_error
  end

end