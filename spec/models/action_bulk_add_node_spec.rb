require 'spec_helper'

describe ActionBulkAddNode do
  subject { create(:action_bulk_add_node) }

  it "should return nodes" do
    subject.nodes.should be_empty
    ActionBulkAddNode.perform(subject.id)
    subject.reload.nodes.size.should > 0
    subject.nodes.first.is_a?(::Node).should be_true
  end
  
  it 'should add nodes to a tree' do
    parent = Node.find(subject.parent_id)
    parent.has_children?.should be_false
    ActionBulkAddNode.perform(subject.id)
    node_ids = JSON.parse(subject.reload.json_message, symbolize_names: true)[:undo]
    parent.reload.has_children?.should be_true
    parent.children.size.should == node_ids.size
    parent.children.map(&:id).should == node_ids
    subject.undo?.should be_true
    ActionBulkAddNode.perform(subject.id)
    parent.has_children?.should be_false
  end
  
  it 'should not add nodes if precondition is not met' do
    aa = create(:action_bulk_add_node)
    Node.find(aa.parent_id).destroy
    expect{ ActionBulkAddNode.perform(aa.id) }.to raise_error
    aa = create(:action_bulk_add_node)
    aa.json_message = nil
    aa.save!
    expect{ ActionBulkAddNode.perform(aa.id) }.to raise_error
  end

  it 'should not undo adding nodes if precondition is not met' do
    aa = create(:action_bulk_add_node)
    ActionBulkAddNode.perform(aa.id)
    aa.json_message = nil
    aa.save!
    expect{ ActionBulkAddNode.perform(aa.id) }.to raise_error
  end


end
