require 'spec_helper'

describe ReferenceTree do
  it { should be_kind_of(Tree) }
  it { should have_many(:master_trees).through(:reference_tree_collections) }
  it { should validate_presence_of(:revision) }
  it { should validate_presence_of(:publication_date) }

  it "should create a new tree from a list of nodes" do
    tree = create :tree, :title => "My title"
    ReferenceTree.stubs(:new => tree)
    ReferenceTree.create_from_list({:title => "My title"}, ["kitten", "bunny"])
    tree.nodes.map{ |node| node.name_string }.should == ["tree_root", "kitten", "bunny"]
  end
end
