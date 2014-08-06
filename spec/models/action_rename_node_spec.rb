require 'spec_helper'

describe ActionRenameNode do
  subject { create(:action_rename_node) }

  it 'should return node' do
    subject.node.should == Node.find(subject.node_id)
  end

  it 'should return master_tree' do
    subject.master_tree.should == subject.node.tree
  end

  it 'should rename the node on first perform and get old name on second perform' do
    node = Node.find(subject.node_id)
    old_node_name = node.name.name_string
    old_node_name.should == subject.old_name
    old_node_name.should_not == subject.new_name
    ActionRenameNode.perform(subject.id)
    node.reload.name.name_string.should == subject.new_name
    subject.reload.undo?.should be_truthy
    ActionRenameNode.perform(subject.id)
    node.reload.name.name_string.should == old_node_name
  end

  it 'should not rename if preconditions is not met' do
    ar = create(:action_rename_node)
    Node.find(ar.node_id).destroy
    expect{ ActionRenameNode.perform(ar.id) }.to raise_error
  end

  it 'should not undo rename if precondition is not met' do
    ar = create(:action_rename_node)
    node = Node.find(ar.node_id)
    ActionRenameNode.perform(ar.id)
    node.reload.name.name_string.should == ar.new_name
    node.destroy
    expect{ ActionRenameNode.perform(ar.id) }.to raise_error
  end

end
