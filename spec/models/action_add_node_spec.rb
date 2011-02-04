require 'spec_helper'

describe ActionAddNode do
  subject { Factory(:action_add_node) }

  it 'should add a node to a tree' do
    subject.node_id.should be_nil
    parent = Node.find(subject.parent_id)
    parent.has_children?.should be_false
    ActionAddNode.perform(subject.id)
    parent.reload.has_children?.should be_true
    parent.children.size.should == 1
    parent.children[0].id.should == subject.reload.node_id
    subject.undo?.should be_true
    ActionAddNode.perform(subject.id)
    parent.has_children?.should be_false
    subject.reload.node_id.should be_nil
  end

  it 'should not add a node if precondition is not met' do
    aa = Factory(:action_add_node)
    Node.find(aa.parent_id).destroy
    expect{ ActionAddNode.perform(aa.id) }.to raise_error
  end

  it 'should not add a node if precondition is not met' do
    aa = Factory(:action_add_node)
    Node.find(aa.parent_id).has_children?.should be_false
    ActionAddNode.perform(aa)
    Node.find(aa.reload.parent_id).has_children?.should be_true
    Node.find(aa.node_id).destroy
    expect{ ActionAddNode.perform(aa.id) }.to raise_error
  end
  
end
