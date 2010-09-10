require 'spec_helper'

describe Node do
  it { should belong_to :tree }
  it { should validate_presence_of :tree_id }
  it { should validate_presence_of :name }

  it "should support constructing a hierarchy" do
    root = Factory(:node)
    child = Factory(:node, :parent => root)
    grandchild = Factory(:node, :parent => child)

    root.children.should == [child]
    grandchild.parent.parent.should == root
  end

  it "should produce a deep copy of its subtree, with node names, on #deep_copy" do
    root = Factory(:node, :name => 'Root')
    child = Factory(:node, :parent => root, :name => 'Child')
    grandchild = Factory(:node, :parent => child, :name => 'Grandchild')

    another_root = root.deep_copy

    another_root.name.should == 'Root'
    another_root.children.size.should == 1
    another_root.children.first.name.should == 'Child'
    another_root.children.first.children.size.should == 1
    another_root.children.first.children.first.name.should == 'Grandchild'
  end

  it "can find a node by id scoped under a user" do
    right_user = Factory(:user)
    wrong_user = Factory(:user)
    right_user_tree = Factory(:tree, :user => right_user)

    Factory(:tree, :user => right_user)
    Factory(:tree, :user => wrong_user)

    node = Factory(:node, :tree => right_user_tree)

    Node.find_by_id_for_user(node.id, right_user).should == node
    Node.find_by_id_for_user(node.id, wrong_user).should be_nil
  end
end
