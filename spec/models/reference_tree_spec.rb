require 'spec_helper'

describe ReferenceTree do
  it { should be_kind_of(Tree) }
  it { should belong_to(:master_tree) }

  it "should create a new tree from a list of nodes" do
    tree = Factory :tree, :title => "My title"
    ReferenceTree.stubs(:new => tree)
    ReferenceTree.create_from_list({:title => "My title"}, ["kitten", "bunny"])
    tree.nodes.map{|node| node.name}.should == ["kitten", "bunny"]
  end
end
