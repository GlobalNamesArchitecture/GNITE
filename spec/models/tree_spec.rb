require 'spec_helper'

describe Tree do
  it { should validate_presence_of :title }
  it { should validate_presence_of :user_id }
  it { should have_many(:nodes) }
  it { should belong_to(:user) }
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

  it "should automatically have a root node" do
    tree = Factory(:tree)
    nodes = Node.find_all_by_tree_id(tree.id)
    nodes.size.should == 1
    nodes[0].parent_id.should == nil
    nodes[0].name.name_string.should == Gnite::Config.root_node_name_string
  end

  it "should have one and only one root node" do
    tree = Factory(:tree)
    3.times { Factory(:node, :tree => tree) }
    10.times do
      parent = Node.where(:tree_id => tree.id).shuffle[0]
      Factory(:node, :tree => tree, :parent_id => parent.id)
    end
    roots = Node.where(:tree_id => tree.id).where(:parent_id => nil)
    roots.size.should == 1
    tree.root.should == roots[0]
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
    root_real = tree.root
    root1 = Factory(:node, :tree => tree)
    root2 = Factory(:node, :tree => tree)
    child1 = Factory(:node, :parent => root1, :tree => tree)

    tree.children_of(nil).should == [root_real]
    tree.children_of(tree.root).should == [root1, root2]
  end
end

describe Tree, 'finding in sorted by title' do
  let(:user) { Factory(:email_confirmed_user) }
  let(:z_tree) { Factory(:master_tree, :title => 'z', :user => user) }
  let(:b_tree) { Factory(:master_tree, :title => 'b', :user => user) }
  let(:a_tree) { Factory(:master_tree, :title => 'a', :user => user) }

  it 'finds the trees in ascending title order' do
    user.master_trees.by_title.should == [a_tree, b_tree, z_tree]
  end
end

describe Tree, '#nuke' do
  it "should destroy all nodes, synonyms and vernaculars" do
    user = Factory(:email_confirmed_user)
    tree = Factory(:tree, :user => user)
    root = Factory(:node, :tree => tree)
    child = Factory(:node, :tree => tree, :parent_id => root)
    grandchild = Factory(:node, :tree => tree, :parent_id => child)
    vern = Factory(:vernacular_name, :node => child)
    syn = Factory(:synonym, :node => grandchild)
    tree_id = tree.id
    tree_count = Tree.count
    node_count = Node.count
    vern_count = VernacularName.count
    syn_count = Synonym.count
    tree.nuke
    (tree_count - Tree.count).should == 1
    (node_count - Node.count).should == 4
    (vern_count - VernacularName.count).should == 1
    (syn_count - Synonym.count).should == 1
  end
end
