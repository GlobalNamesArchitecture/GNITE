require 'spec_helper'

describe UndoActionCommand do
  let(:master_tree) { Factory(:master_tree) }
  let(:action_add_node1) { Factory(:action_add_node, :tree_id => master_tree.id, :parent_id => master_tree.root.id) }
  let(:action_add_node2) { Factory(:action_add_node, :tree_id => master_tree.id, :parent_id => action_add_node1.node.id) }
  let(:action_add_node3) { Factory(:action_add_node, :tree_id => master_tree.id, :parent_id => action_add_node2.node.id) }
  let(:action_add_node4) { Factory(:action_add_node, :tree_id => master_tree.id, :parent_id => action_add_node3.node.id) }
  let(:action_add_node5) { Factory(:action_add_node, :tree_id => master_tree.id, :parent_id => action_add_node4.node.id) }
  let(:undo_actions) { UndoActionCommand.undo_actions(master_tree.id) }

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
      ra = Factory(:action_rename_node, :tree_id => master_tree.id, :node_id => action_add_node1.node.id, :new_name => "node1_rename_#{i+1}")
      ra.class.perform(ra.id)
      ra.reload
    end
  end

  it 'should register undo statements' do
    # assuming here theat undo limit is 10
    undo_actions.size.should == Gnite::Config.undo_limit
  end

  it 'should be able to undo several statements' do
    undo_count = UndoActionCommand.count
    redo_count = RedoActionCommand.count
    
    3.times { UndoActionCommand.undo(master_tree.id, '9999') }
    (undo_count - UndoActionCommand.count).should == 3
    (RedoActionCommand.count  - redo_count).should == 3
    action_add_node1.reload.node.reload.name.name_string.should == 'node1_rename_3'
    ra = Factory(:action_rename_node, :tree_id => master_tree.id, :node_id => action_add_node5.node.id, :new_name => "renamed_name")
    ra.class.perform(ra.id)
    (undo_count - UndoActionCommand.count).should == 2
  end

end

