require 'spec_helper'

describe ActionCopyNodeFromAnotherTree do
  subject { create(:action_copy_node_from_another_tree) }

  it 'should return node' do
    subject.node.should == Node.find(subject.node_id)
  end

  it 'should return master_tree' do
    subject.master_tree.should == Node.find(subject.destination_parent_id).tree
  end

  it 'should copy the node on first perform and remove it on second perform' do
    node = subject.node
    child = create(:node, :parent => node, :tree => node.tree)
    grandchild = create(:node, :parent => child, :tree => node.tree)
    old_parent_id = node.parent_id
    new_parent_id = subject.destination_parent_id
    ActionCopyNodeFromAnotherTree.perform(subject.id)
    node.parent_id.should == old_parent_id
    Node.find(new_parent_id).children.select { |c| c.name == node.name && c.children[0].name == node.children[0].name && c.children[0].children[0].name == node.children[0].children[0].name }.size.should == 1
    subject.reload.undo?.should be_truthy
    JSON.parse(subject.json_message, :symbolize_names => true).keys.should == [:node]
    ActionCopyNodeFromAnotherTree.perform(subject.id)
    node.reload.parent_id.should == old_parent_id
    Node.find(new_parent_id).children.select { |c| c.name == node.name }.size == 0
    subject.reload.undo?.should be_falsey
  end

  it 'should not try to copy the node if node does not exist' do
    subject = create(:action_copy_node_from_another_tree)
    subject.node.destroy
    expect { ActionCopyNodeFromAnotherTree.perform(subject.id) }.to raise_error
  end

  it 'should not try to copy the node if destination does not exist' do
    subject = create(:action_copy_node_from_another_tree)
    dest_node = Node.find(subject.destination_parent_id)
    dest_node.destroy
    expect { ActionCopyNodeFromAnotherTree.perform(subject.id) }.to raise_error
  end

  it 'should not try to copy the node if ancestry of parent is broken' do
    subject = create(:action_copy_node_from_another_tree)
    destination_parent_node = Node.find(subject.destination_parent_id)
    destination_parent_node.parent = create(:node)
    expect { ActionCopyNodeFromAnotherTree.perform(subject.id) }.to raise_error
  end

  it 'should not try to undo copy the node if node does not exist' do
    subject = create(:action_copy_node_from_another_tree)
    ActionCopyNodeFromAnotherTree.perform(subject.id)
    subject.reload.undo?.should be_truthy
    destination_node = Node.find(subject.destination_node_id)
    destination_node.destroy
    expect { ActionCopyNodeFromAnotherTree.perform(subject.id) }.to raise_error
  end

end
