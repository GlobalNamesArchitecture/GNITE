require 'spec_helper'

describe RedoActionCommand do
  let(:master_tree) { create(:master_tree) }
  let(:action_add_node1) { create(:action_add_node, :tree_id => master_tree.id, :parent_id => master_tree.root.id) }
  let(:action_add_node2) { create(:action_add_node, :tree_id => master_tree.id, :parent_id => action_add_node1.node.id) }
  let(:action_add_node3) { create(:action_add_node, :tree_id => master_tree.id, :parent_id => action_add_node2.node.id) }
  let(:action_add_node4) { create(:action_add_node, :tree_id => master_tree.id, :parent_id => action_add_node3.node.id) }
  let(:action_add_node5) { create(:action_add_node, :tree_id => master_tree.id, :parent_id => action_add_node4.node.id) }
  let(:redo_actions) { RedoActionCommand.redo_actions(master_tree.id) }

  before do
    ActionAddNode.perform(action_add_node1.id)
    action_add_node1.reload
    ActionAddNode.perform(action_add_node2.id)
    action_add_node2.reload
    ActionAddNode.perform(action_add_node3.id)
    action_add_node3.reload
    ActionAddNode.perform(action_add_node4.id)
    action_add_node4.reload
    ActionAddNode.perform(action_add_node5.id)
    action_add_node5.reload
    6.times do |i|
      ra = create(:action_rename_node, :tree_id => master_tree.id, :node_id => action_add_node1.node.id, :new_name => "node1_rename_#{i+1}")
      ra.class.perform(ra.id)
      ra.reload
    end
    3.times { UndoActionCommand.undo(master_tree.id, '9999') }
  end

  it 'should register undo statements' do
    redo_actions.size.should == 3
  end

  it 'should be able to undo several statements' do
    action_add_node1.reload.node.reload.name.name_string.should == 'node1_rename_3'
    undo_count = UndoActionCommand.count
    redo_count = RedoActionCommand.count
    redo_count.should == 3
    2.times { RedoActionCommand.redo(master_tree.id, '9999') }
    (UndoActionCommand.count - undo_count).should == 2
    (redo_count - RedoActionCommand.count).should == 2
    action_add_node1.reload.node.reload.name.name_string.should == 'node1_rename_5'
    ra = create(:action_rename_node, :tree_id => master_tree.id, :node_id => action_add_node5.node.id, :new_name => "renamed_name")
    ra.class.perform(ra.id)
    (UndoActionCommand.count - undo_count).should == 3
    RedoActionCommand.count.should == 0
  end

end

