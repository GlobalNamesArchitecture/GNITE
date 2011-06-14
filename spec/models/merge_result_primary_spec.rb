require 'spec_helper'

describe MergeResultPrimary do

  before(:all) do
    require 'ruby-debug'; debugger
    @tree1 = get_tree1
    @tree2 = get_tree2
    primary_node = @tree1.root.children.first
    secondary_node = @tree2.root.children.first
    @me = MergeEvent.create(:master_tree => @tree1, :primary_node_id => primary_node.id, :secondary_node_id => secondary_node.id, :user => Factory(:user))
  end

  it "should process merge results" do
    MergeResultPrimary.import_merge(@me)  
    @me.merge_result.should == ''
  end
end
