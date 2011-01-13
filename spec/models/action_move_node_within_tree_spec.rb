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
end
