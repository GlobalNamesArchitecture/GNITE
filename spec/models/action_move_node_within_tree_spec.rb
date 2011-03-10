require 'spec_helper'

describe ActionMoveNodeWithinTree do

  it 'should move the node on first perform and move it back on second perform' do
    subject = Factory(:action_move_node_within_tree)
    node = Node.find(subject.node_id)
    old_parent_id = node.parent_id
    new_parent_id = subject.destination_parent_id
    ActionMoveNodeWithinTree.perform(subject.id)
    node.reload.parent_id.should == new_parent_id
    subject.reload.undo?.should be_true
    ActionMoveNodeWithinTree.perform(subject.id)
    node.reload.parent_id.should == old_parent_id
    subject.reload.undo?.should be_false
  end

  it 'should not try to move the node if node does not exist' do
    am = Factory(:action_move_node_within_tree)
    node = Node.find(am.node_id)
    node.destroy
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to move the node if destination does not exist' do
    am = Factory(:action_move_node_within_tree)
    dest_node = Node.find(am.destination_parent_id)
    dest_node.destroy
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to move the node if parent_id does not exist' do
    am = Factory(:action_move_node_within_tree)
    parent_node = Node.find(am.parent_id)
    parent_node.destroy
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to move the node if ancestry of parent is broken' do
    am = Factory(:action_move_node_within_tree)
    parent_node = Node.find(am.parent_id)
    parent_node.parent = Factory(:node)
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to move the node if ancestry of destination parent is broken' do
    am = Factory(:action_move_node_within_tree)
    dest_node = Node.find(am.destination_parent_id)
    dest_node.parent = Factory(:node)
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to move the node if parent and destination are in different trees' do
    am = Factory(:action_move_node_within_tree, :destination_parent_id => Factory(:node).id)
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to undo a move of the node if node does not exist' do
    am = Factory(:action_move_node_within_tree, :undo => true)
    am.undo.should == true
    node = Node.find(am.node_id)
    node.destroy
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to undo a move of the node if destination does not exist' do
    am = Factory(:action_move_node_within_tree, :undo => true)
    dest_node = Node.find(am.destination_parent_id)
    dest_node.destroy
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to undo a move of the node if parent_id does not exist' do
    am = Factory(:action_move_node_within_tree, :undo => true)
    parent_node = Node.find(am.parent_id)
    parent_node.destroy
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to undo a move of the node if ancestry of parent is broken' do
    am = Factory(:action_move_node_within_tree, :undo => true)
    parent_node = Node.find(am.parent_id)
    parent_node.parent = Factory(:node)
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to undo a move of the node if ancestry of destination parent is broken' do
    am = Factory(:action_move_node_within_tree, :undo => true)
    dest_node = Node.find(am.destination_parent_id)
    dest_node.parent = Factory(:node)
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end

  it 'should not try to undo a move of the node if parent and destination are in different trees' do
    am = Factory(:action_move_node_within_tree, :undo => true, :destination_parent_id => Factory(:node).id)
    expect { ActionMoveNodeWithinTree.perform(am.id) }.to raise_error
  end
end
