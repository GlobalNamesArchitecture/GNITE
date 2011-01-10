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

  it 'should by default be a child of the root node' do
    root = Factory(:node)
    child = Factory(:node, :parent => root)
    real_root = root.tree.root
    real_root.children.should == [root]
    root.children.should == [child]
  end
end

describe Node, 'finding by id scoped to a user' do
  let(:right_user) { Factory(:user) }
  let(:right_tree) { Factory(:master_tree, :user => right_user) }
  let(:wrong_user) { Factory(:user) }
  let(:wrong_tree) { Factory(:master_tree, :user => wrong_user) }
  let(:node)       { Factory(:node, :tree => right_tree) }

  it "can find a node by id scoped under a user" do
    Node.find_by_id_for_user(node.id, right_user).should == node
    Node.find_by_id_for_user(node.id, wrong_user).should be_nil
  end
end

describe Node, '#deep_copy_to' do
  it 'produces a deep copy of its subtree, with node names, synonyms, and vernacular names' do
    tree        = Factory(:reference_tree)
    root        = Factory(:node, :tree => tree, :name => Factory(:name, :name_string => 'Root'))
    child       = Factory(:node, :tree => tree, :parent => root, :name => Factory(:name, :name_string => 'Child'))
    grandchild  = Factory(:node, :tree => tree, :parent => child, :name => Factory(:name, :name_string => 'Grandchild'))
    master_tree = Factory(:master_tree)

    synonym         = Factory(:synonym, :node => grandchild)
    vernacular_name = Factory(:vernacular_name, :node => child)

    another_root = root.deep_copy_to(master_tree)
    another_root.name_string.should == 'Root'
    another_root.tree.should == master_tree

    another_root.children.size.should == 1
    another_root.children.first.name_string.should == 'Child'
    another_root.children.first.tree.should == master_tree
    another_root.children.first.vernacular_names.size.should == 1
    another_root.children.first.vernacular_names.first.name.should == vernacular_name.name

    another_root.children.first.children.size.should == 1
    another_root.children.first.children.first.name_string.should == 'Grandchild'
    another_root.children.first.children.first.tree.should == master_tree
    another_root.children.first.children.first.synonyms.size.should == 1
    another_root.children.first.children.first.synonyms.first.name.should == synonym.name
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

describe Node, '#rank_string' do
  it 'returns None if rank is nil' do
    node = Factory(:node, :rank => nil)
    node.rank_string.should == 'None'
  end

  it 'returns None if rank is empty' do
    node = Factory(:node, :rank => '  ')
    node.rank_string.should == 'None'
  end

  it 'returns rank if present' do
    node = Factory(:node, :rank => 'Family')
    node.rank_string.should == 'Family'
  end
end

describe Node, '#synonym_name_strings with valid and invalid names' do
  let(:node) { Factory(:node) }

  before do
    @valid_synonym   = Factory(:synonym, :node => node)
    @invalid_synonym = Factory(:synonym, :node => node)
    @invalid_synonym.name.destroy
  end

  it 'returns name strings from valid synonyms' do
    node.synonym_name_strings.should == [@valid_synonym.name.name_string]
  end
end

describe Node, '#synonym_name_strings with no synonyms' do
  let(:node) { Factory(:node) }

  it 'returns None' do
    node.synonym_name_strings.should == ['None']
  end
end

describe Node, '#vernacular_name_strings with valid and invalid names' do
  let(:node) { Factory(:node) }

  before do
    @valid_vernacular_name   = Factory(:vernacular_name, :node => node)
    @invalid_vernacular_name = Factory(:vernacular_name, :node => node)
    @invalid_vernacular_name.name.destroy
  end

  it 'returns name strings from valid vernacular names' do
    node.vernacular_name_strings.should == [@valid_vernacular_name.name.name_string]
  end
end

describe Node, '#vernacular_name_strings with no synonyms' do
  let(:node) { Factory(:node) }

  it 'returns None' do
    node.vernacular_name_strings.should == ['None']
  end
end

describe Node, "#children" do
  let (:parent) { Factory(:node) }
  let (:names) do
    %w{ Gossleriellaceae 
      Stictodiscaceae 
      Arachnoidiscaceae 
      Leptocylindraceae 
      Corethraceae 
      Heliopeltaceae 
      Ethmodiscaceae }.map { |n| Factory(:name, :name_string => n) }
  end
  let (:children_nodes) { names.map{ |name| Factory(:node, :tree_id => parent.tree_id, :parent_id => parent.id, :name => name) } }

  it 'should sort names by alphabet' do
    unsorted_names = children_nodes.map { |node| node.name.name_string }
    unsorted_names.should_not == unsorted_names.sort
    parent.children.map { |node| node.name.name_string }.should == names.map { |name| name.name_string }.sort
  end

  it 'should work with a subset of fields' do
    children_nodes #won't load implicitly
    first_child = parent.reload.children('id')[0]
    first_child.tree.should be_nil
    first_child.name.should be_nil
    first_child.id.is_a?(Fixnum).should be_true
    first_child_full = parent.children[0]
    first_child_full.tree.should_not be_nil
    first_child_full.name.should_not be_nil
    first_child_full.id.should_not be_nil
  end
end

describe Node, '#destroy_with_children' do
  it 'deletes the node and its descendents, related synonyms and vernacular names' do
    tree        = Factory(:reference_tree)
    root        = Factory(:node, :tree => tree, :name => Factory(:name, :name_string => 'Root'))
    child       = Factory(:node, :tree => tree, :parent => root, :name => Factory(:name, :name_string => 'Child'))
    grandchild  = Factory(:node, :tree => tree, :parent => child, :name => Factory(:name, :name_string => 'Grandchild'))
    master_tree = Factory(:master_tree)

    synonym         = Factory(:synonym, :node => grandchild)
    vernacular_name = Factory(:vernacular_name, :node => child)
    nodes_count = Node.count
    vern_count = VernacularName.count
    syn_count = Synonym.count
    root.destroy_with_children
    (nodes_count - Node.count).should == 3
    (vern_count - VernacularName.count).should == 1
    (syn_count - Synonym.count).should == 1
  end
end
