require 'spec_helper'

describe MergeEvent do
  it { should belong_to(:master_tree) }
  it { should belong_to(:user) }
  it { should belong_to(:node) }
  it { should have_many(:merge_result_primaries) }

  before(:all) do
    @tree1 = get_tree1
    @tree2 = get_tree2
    primary_node = @tree1.root.children.first
    secondary_node = @tree2.root.children.first
    @me = MergeEvent.create(:master_tree => @tree1, :primary_node_id => primary_node.id, :secondary_node_id => secondary_node.id, :user => Factory(:user))
  end

  it "should run the merge" do
    merges = @me.merge
    merges.is_a?(Hash).should be_true
    merges.keys.select { |k| !k.is_a?(Symbol) }.should be_empty
    merges.keys.size.should > 0
  end

  it "should create a temporary tree from merged results" do
    MergeResultPrimary.import_merge(@me)  
    merge_tree = @me.make_merged_tree
    merge_tree.is_a?(Tree).should be_true
  end

end
