require 'spec_helper'

describe ActionAddNode do
  subject { create(:action_add_node) }

  it 'should return node' do
    subject.node.should be_nil
    ActionAddNode.perform(subject.id)
    subject.reload.node.is_a?(::Node).should be_truthy
  end

  it 'should return master tree' do
    subject.master_tree.should == Node.find(subject.parent_id).tree
  end

  it 'should add a node to a tree' do
    subject.node_id.should be_nil
    parent = Node.find(subject.parent_id)
    parent.has_children?.should be_falsey
    ActionAddNode.perform(subject.id)
    parent.reload.has_children?.should be_truthy
    parent.children.size.should == 1
    parent.children[0].id.should == subject.reload.node_id
    subject.undo?.should be_truthy
    ActionAddNode.perform(subject.id)
    parent.has_children?.should be_falsey
    subject.reload.node_id.should be_nil
  end

  it 'should not add a node if precondition is not met' do
    aa = create(:action_add_node)
    Node.find(aa.parent_id).destroy
    expect{ ActionAddNode.perform(aa.id) }.to raise_error
  end

  it 'should not add a node if precondition is not met' do
    aa = create(:action_add_node)
    Node.find(aa.parent_id).has_children?.should be_falsey
    ActionAddNode.perform(aa)
    Node.find(aa.reload.parent_id).has_children?.should be_truthy
    Node.find(aa.node_id).destroy
    expect{ ActionAddNode.perform(aa.id) }.to raise_error
  end

end
