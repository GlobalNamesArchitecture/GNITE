require 'spec_helper'

describe ActionMoveNodeToDeletedTree do

  it 'should move the node on first perform and move it back on second perform' do
    subject = Factory(:action_move_node_to_deleted_tree)
    node = Node.find(subject.node_id)
    old_parent_id = node.parent_id
    ActionMoveNodeToDeletedTree.perform(subject.id)
    node.reload.parent_id.should == Node.find(old_parent_id).tree.deleted_tree.root.id
    subject.reload.undo?.should be_true
    ActionMoveNodeToDeletedTree.perform(subject.id)
    node.reload.parent_id.should == old_parent_id
    subject.reload.undo?.should be_false
  end

  it 'should not try to move the node if node does not exist' do
    am = Factory(:action_move_node_to_deleted_tree)
    node = Node.find(am.node_id)
    node.destroy
    expect { ActionMoveNodeToDeletedTree.perform(am.id) }.to raise_error
  end

  it 'should not try to move the node if parent_id does not exist' do
    am = Factory(:action_move_node_to_deleted_tree)
    parent_node = Node.find(am.parent_id)
    parent_node.destroy
    expect { ActionMoveNodeToDeletedTree.perform(am.id) }.to raise_error
  end

  it 'should not try to move the node if ancestry of parent is broken' do
    am = Factory(:action_move_node_to_deleted_tree)
    parent_node = Node.find(am.parent_id)
    parent_node.parent_id = Factory(:node).id
    parent_node.save!
    parent_node.reload
    require 'ruby-debug'; debugger
    expect { ActionMoveNodeToDeletedTree.perform(am.id) }.to raise_error
  end

  it 'should not try to undelete a node if node does not exist' do
    am = Factory(:action_move_node_to_deleted_tree)
    ActionMoveNodeToDeletedTree.perform(am.id)
    am.reload.undo?.should be_true
    node = Node.find(am.node_id)
    node.destroy
    expect { ActionMoveNodeToDeletedTree.perform(am.id) }.to raise_error
  end

  it 'should not try to move the node if parent_id does not exist' do
    am = Factory(:action_move_node_to_deleted_tree)
    ActionMoveNodeToDeletedTree.perform(am.id)
    am.reload.undo?.should be_true
    parent_node = Node.find(am.parent_id)
    parent_node.destroy
    expect { ActionMoveNodeToDeletedTree.perform(am.id) }.to raise_error
  end

  it 'should not try to move the node if ancestry of parent is broken' do
    am = Factory(:action_move_node_to_deleted_tree)
    ActionMoveNodeToDeletedTree.perform(am.id)
    am.reload.undo?.should be_true
    parent_node = Node.find(am.parent_id)
    parent_node.parent = Factory(:node)
    expect { ActionMoveNodeToDeletedTree.perform(am.id) }.to raise_error
  end


end
