require 'spec_helper'

describe MergeTree do
  it { should have_one(:merge_event) }
  
  before(:all) do
    @tree1 = get_tree1
    @tree2 = get_tree2
    primary_node = @tree1.root.children.first
    secondary_node = @tree2.root.children.first
    @me = MergeEvent.create(:master_tree => @tree1, :primary_node_id => primary_node.id, :secondary_node_id => secondary_node.id, :user => Factory(:user))
    @merge_tree = @me.merge_tree
  end
  
  it "should populate tree with merge results" do
    MergeResultPrimary.import_merge(@me)
    @me.merge_result_primaries.each do |primary|
      primary.merge_result_secondaries.each do |secondary|
        secondary.merge_decision = MergeDecision.accepted
        secondary.save!
        secondary.reload
      end
    end
    @merge_tree.nodes.size.should == 1
    @merge_tree.populate
    @merge_tree.nodes.size.should == 18
    @merge_tree.nodes.map {|n| n.synonyms}.flatten.compact.size.should == 6
  end
end
