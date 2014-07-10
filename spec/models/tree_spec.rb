require 'spec_helper'

describe Tree do
  it { should validate_presence_of :title }
  it { should have_many(:nodes) }
  it { should allow_value('publicdomain').for(:creative_commons) }
  it { should_not allow_value('something else').for(:creative_commons) }

  it "should know the children of a node inside it" do
    tree = create(:tree)

    parent = create(:node, :tree => tree)
    child1 = create(:node, :parent => parent, :tree => tree)
    child2 = create(:node, :parent => parent, :tree => tree)

    tree.children_of(parent).should == [child1, child2]
    tree.children_of(parent.id).should == [child1, child2]
  end

  it "should automatically have a root node" do
    tree = create(:tree)
    nodes = Node.find_all_by_tree_id(tree.id)
    nodes.size.should == 1
    nodes[0].parent_id.should == nil
    nodes[0].name.name_string.should == Gnite::Config.root_node_name_string
  end

  it "should have one and only one root node" do
    tree = create(:tree)
    3.times { create(:node, :tree => tree) }
    10.times do
      parent = Node.where(:tree_id => tree.id).shuffle[0]
      create(:node, :tree => tree, :parent_id => parent.id)
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
    tree = create(:tree, :uuid => "uuid monster")
    tree.save
    tree.uuid.should == "uuid monster"
  end

  it "should raise ActiveRecord::RecordNotFound when asking for the children of a node not in the tree" do
    tree = create(:tree)

    parent = create(:node, :tree => tree)
    child1 = create(:node, :parent => parent, :tree => tree)
    child2 = create(:node, :parent => parent, :tree => tree)

    other_tree = create(:tree)

    lambda { other_tree.children_of(parent) }.should raise_error(ActiveRecord::RecordNotFound)
  end

  it "should know the roots inside it" do
    tree = create(:tree)
    root_real = tree.root
    root1 = create(:node, :tree => tree)
    root2 = create(:node, :tree => tree)
    child1 = create(:node, :parent => root1, :tree => tree)

    tree.children_of(nil).should == [root_real]
    tree.children_of(tree.root).should == [root1, root2]
  end
end

describe Tree, '#nuke_nodes' do
  it "should destroy all nodes, but not the tree and its root" do
    user = create(:user)
    tree = create(:tree)
    root = create(:node, :tree => tree)
    child = create(:node, :tree => tree, :parent_id => root)
    grandchild = create(:node, :tree => tree, :parent_id => child)
    bookmark = create(:bookmark, :node => child)
    vern = create(:vernacular_name, :node => child)
    syn = create(:synonym, :node => grandchild)
    tree_id = tree.id
    tree_count = Tree.count
    root = tree.root
    node_count = Node.count
    bookmark_count = Bookmark.count
    vern_count = VernacularName.count
    syn_count = Synonym.count
    tree.nuke_nodes
    (tree_count - Tree.count).should == 0
    tree.reload.root.should == root
    (node_count - Node.count).should == 3
    (bookmark_count - Bookmark.count).should == 1
    (vern_count - VernacularName.count).should == 1
    (syn_count - Synonym.count).should == 1
  end
end

describe Tree, '#nuke' do
  it "should destroy all nodes, bookmarks, synonyms and vernaculars" do
    user = create(:user)
    tree = create(:tree)
    root = create(:node, :tree => tree)
    child = create(:node, :tree => tree, :parent_id => root)
    grandchild = create(:node, :tree => tree, :parent_id => child)
    bookmark = create(:bookmark, :node => child)
    vern = create(:vernacular_name, :node => child)
    syn = create(:synonym, :node => grandchild)
    tree_id = tree.id
    tree_count = Tree.count
    node_count = Node.count
    bookmark_count = Bookmark.count
    vern_count = VernacularName.count
    syn_count = Synonym.count
    tree.nuke
    (tree_count - Tree.count).should == 1
    (node_count - Node.count).should == 4
    (bookmark_count - Bookmark.count).should == 1
    (vern_count - VernacularName.count).should == 1
    (syn_count - Synonym.count).should == 1
  end
end
