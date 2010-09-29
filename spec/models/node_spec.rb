require 'spec_helper'

describe Node, 'valid' do
  it { should belong_to :tree }
  it { should belong_to :name }
  it { should validate_presence_of :tree_id }

  it { should have_many :synonyms }
  it { should have_many :vernacular_names }

  it 'supports constructing a hierarchy' do
    root = Factory(:node)
    child = Factory(:node,      :parent => root)
    grandchild = Factory(:node, :parent => child)

    root.children.should == [child]
    grandchild.parent.parent.should == root
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

describe Node, '#deep_copy_to' do
  it 'produces a deep copy of its subtree, with node names' do
    tree        = Factory(:reference_tree)
    root        = Factory(:node, :tree => tree, :name => Factory(:name, :name_string => 'Root'))
    child       = Factory(:node, :tree => tree, :parent => root, :name => Factory(:name, :name_string => 'Child'))
    grandchild  = Factory(:node, :tree => tree, :parent => child, :name => Factory(:name, :name_string => 'Grandchild'))
    master_tree = Factory(:master_tree)

    another_root = root.deep_copy_to(master_tree)
    another_root.name_string.should == 'Root'
    another_root.tree.should == master_tree

    another_root.children.size.should == 1
    another_root.children.first.name_string.should == 'Child'
    another_root.children.first.tree.should == master_tree

    another_root.children.first.children.size.should == 1
    another_root.children.first.children.first.name_string.should == 'Grandchild'
    another_root.children.first.children.first.tree.should == master_tree
  end
end

describe Node, 'name' do
  let(:name) { Factory(:name) }
  subject { Factory(:node, :name => name) }

  it 'delegates name to the Name model' do
    subject.name_string.should == name.name_string
    name.name_string = 'a new name'
    subject.name_string.should == 'a new name'
  end
end
