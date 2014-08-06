require 'spec_helper'

describe ActionMoveNodeToDeletedTree do
  subject { create(:action_move_node_to_deleted_tree) }

  it 'should return node' do
    subject.node.should == Node.find(subject.node_id)
  end

  it 'should return master_tree' do
    subject.master_tree.should == subject.node.tree
    ActionMoveNodeToDeletedTree.perform(subject.id)
    subject.master_tree.should == subject.node.reload.tree.master_tree
  end

  it 'should move the node on first perform and move it back on second perform' do
    node = subject.node
    old_parent_id = node.parent_id
    ActionMoveNodeToDeletedTree.perform(subject.id)
    node.reload.parent_id.should == Node.find(old_parent_id).tree.deleted_tree.root.id
    subject.reload.undo?.should be_truthy
    ActionMoveNodeToDeletedTree.perform(subject.id)
    node.reload.parent_id.should == old_parent_id
    subject.reload.undo?.should be_falsey
  end

  it 'should not try to move the node if node does not exist' do
    subject = create(:action_move_node_to_deleted_tree)
    node = subject.node
    node.destroy
    expect { ActionMoveNodeToDeletedTree.perform(subject.id) }.to raise_error
  end

  it 'should not try to move the node if parent_id does not exist' do
    subject = create(:action_move_node_to_deleted_tree)
    parent_node = Node.find(subject.parent_id)
    parent_node.destroy
    expect { ActionMoveNodeToDeletedTree.perform(subject.id) }.to raise_error
  end

  it 'should not try to move the node if ancestry of parent is broken' do
    subject = create(:action_move_node_to_deleted_tree)
    parent_node = Node.find(subject.parent_id)
    parent_node.parent_id = create(:node).id
    parent_node.save!
    parent_node.reload
    expect { ActionMoveNodeToDeletedTree.perform(subject.id) }.to raise_error
  end

  it 'should not try to undelete a node if node does not exist' do
    subject = create(:action_move_node_to_deleted_tree)
    ActionMoveNodeToDeletedTree.perform(subject.id)
    subject.reload.undo?.should be_truthy
    node = subject.node
    node.destroy
    expect { ActionMoveNodeToDeletedTree.perform(subject.id) }.to raise_error
  end

  it 'should not try to move the node if parent_id does not exist' do
    subject = create(:action_move_node_to_deleted_tree)
    ActionMoveNodeToDeletedTree.perform(subject.id)
    subject.reload.undo?.should be_truthy
    parent_node = Node.find(subject.parent_id)
    parent_node.destroy
    expect { ActionMoveNodeToDeletedTree.perform(subject.id) }.to raise_error
  end

  it 'should not try to move the node if ancestry of parent is broken' do
    subject = create(:action_move_node_to_deleted_tree)
    ActionMoveNodeToDeletedTree.perform(subject.id)
    subject.reload.undo?.should be_truthy
    parent_node = Node.find(subject.parent_id)
    parent_node.parent = create(:node)
    expect { ActionMoveNodeToDeletedTree.perform(subject.id) }.to raise_error
  end


end
