require 'spec_helper'

describe ActionCopyNodeFromAnotherTree do

  it 'should move the node on first perform and move it back on second perform' do
    subject = Factory(:action_copy_node_from_another_tree)
    node = Node.find(subject.node_id)
    child = Factory(:node, :parent => node, :tree => node.tree)
    grandchild = Factory(:node, :parent => child, :tree => node.tree)
    old_parent_id = node.parent_id
    new_parent_id = subject.destination_parent_id
    ActionCopyNodeFromAnotherTree.perform(subject.id)
    node.reload.parent_id.should == old_parent_id
    Node.find(new_parent_id).children.select { |c| c.name == node.name && c.children[0].name == node.children[0].name && c.children[0].children[0].name == node.children[0].children[0].name }.size.should == 1
    subject.reload.undo?.should be_true
    ActionCopyNodeFromAnotherTree.perform(subject.id)
    node.reload.parent_id.should == old_parent_id
    Node.find(new_parent_id).children.select { |c| c.name == node.name }.size == 0
    subject.reload.undo?.should be_false
  end

  it 'should not try to copy the node if node does not exist' do
    am = Factory(:action_copy_node_from_another_tree)
    node = Node.find(am.node_id)
    node.destroy
    expect { ActionCopyNodeFromAnotherTree.perform(am.id) }.to raise_error
  end

  it 'should not try to copy the node if destination does not exist' do
    am = Factory(:action_copy_node_from_another_tree)
    dest_node = Node.find(am.destination_parent_id)
    dest_node.destroy
    expect { ActionCopyNodeFromAnotherTree.perform(am.id) }.to raise_error
  end

  it 'should not try to copy the node if ancestry of parent is broken' do
    am = Factory(:action_copy_node_from_another_tree)
    destination_parent_node = Node.find(am.destination_parent_id)
    destination_parent_node.parent = Factory(:node)
    expect { ActionCopyNodeFromAnotherTree.perform(am.id) }.to raise_error
  end

  it 'should not try to undo copy the node if node does not exist' do
    am = Factory(:action_copy_node_from_another_tree)
    ActionCopyNodeFromAnotherTree.perform(am.id)
    am.reload.undo?.should be_true
    destination_node = Node.find(am.destination_node_id)
    destination_node.destroy
    expect { ActionCopyNodeFromAnotherTree.perform(am.id) }.to raise_error
  end

end
