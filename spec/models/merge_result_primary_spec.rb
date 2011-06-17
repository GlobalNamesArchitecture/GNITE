require 'spec_helper'

describe MergeResultPrimary do

  it { should belong_to(:merge_event) }
  it { should belong_to(:node) }
  it { should have_many(:merge_result_secondaries) }

  before(:all) do
    @tree1 = get_tree1
    @tree2 = get_tree2
    primary_node = @tree1.root.children.first
    secondary_node = @tree2.root.children.first
    @me = MergeEvent.create(:master_tree => @tree1, :primary_node_id => primary_node.id, :secondary_node_id => secondary_node.id, :user => Factory(:user))
  end

  it "should process merge results" do
    MergeResultPrimary.import_merge(@me)  
    @me.merge_result_primaries.size.should > 0
    @me.merge_result_primaries.first.merge_result_secondaries.size.should > 0
  end
end
