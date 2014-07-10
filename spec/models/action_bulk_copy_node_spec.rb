require 'spec_helper'

describe ActionBulkCopyNode do
  
  subject { create(:action_bulk_copy_node) }
  
  before(:each) do
    reference_tree = create(:reference_tree)
    nodes = []
    3.times { nodes << create(:node, :tree => reference_tree).id }
    subject.json_message = {:do => nodes}.to_json
    subject.save!
  end

  it 'should copy nodes on first perform and remove them on second perform' do
    parent = Node.find(subject.destination_parent_id)
    parent.has_children?.should be_false
    ActionBulkCopyNode.perform(subject.id)
    node_ids = JSON.parse(subject.reload.json_message, :symbolize_names => true)[:undo]
    parent.reload.has_children?.should be_true
    parent.children.size.should == node_ids.size
    parent.children.map(&:id).should == node_ids
    subject.undo?.should be_true
    ActionBulkCopyNode.perform(subject.id)
    parent.has_children?.should be_false
  end
  
  it 'should not bulk copy nodes if precondition is not met' do
    Node.find(subject.destination_parent_id).destroy
    expect{ ActionBulkCopyNode.perform(subject.id) }.to raise_error
    aa = create(:action_bulk_copy_node)
    aa.json_message = nil
    aa.save!
    expect{ ActionBulkCopyNode.perform(aa.id) }.to raise_error
  end
  
  it 'should not undo bulk copy nodes if undo precondition is not met' do
    ActionBulkCopyNode.perform(subject.id)
    subject.json_message = nil
    subject.save!
    expect{ ActionBulkCopyNode.perform(subject.id) }.to raise_error
  end

end