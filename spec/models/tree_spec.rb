require 'spec_helper'

describe Tree do
  it { should validate_presence_of :title }
  it { should validate_presence_of :user_id }
  it { should have_many(:nodes) }
  it { should allow_value('publicdomain').for(:creative_commons) }
  it { should_not allow_value('something else').for(:creative_commons) }

  it "should know the children of a node inside it" do
    tree = Factory(:tree)

    parent = Factory(:node, :tree => tree)
    child1 = Factory(:node, :parent => parent, :tree => tree)
    child2 = Factory(:node, :parent => parent, :tree => tree)

    tree.children_of(parent).should == [child1, child2]
    tree.children_of(parent.id).should == [child1, child2]
  end

  it "should have an automatically generated uuid" do
    subject.uuid.should_not be_nil
  end

  it "should set a default value for creative commons" do
    subject.creative_commons.should == "cc0"
  end

  it "should not assign a new uuid to something with a uuid" do
    tree = Factory(:tree, :uuid => "uuid monster")
    tree.save
    tree.uuid.should == "uuid monster"
  end

  it "should raise ActiveRecord::RecordNotFound when asking for the children of a node not in the tree" do
    tree = Factory(:tree)

    parent = Factory(:node, :tree => tree)
    child1 = Factory(:node, :parent => parent, :tree => tree)
    child2 = Factory(:node, :parent => parent, :tree => tree)

    other_tree = Factory(:tree)

    lambda { other_tree.children_of(parent) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should know the roots inside it" do
    tree = Factory(:tree)

    root1 = Factory(:node, :tree => tree)
    root2 = Factory(:node, :tree => tree)
    child1 = Factory(:node, :parent => root1, :tree => tree)

    tree.children_of(nil).should == [root1, root2]
  end
end
