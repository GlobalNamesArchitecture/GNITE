require 'spec_helper'

describe NodesController, 'when signed out on POST to create' do
  before do
    post :create, :master_tree_id => 123, :node_id => 456
  end
  subject { controller }
  it { should redirect_to(sign_in_url) }
  it { should set_the_flash.to(/sign in/) }
end

describe NodesController do
  context "signed in with a tree and nodes" do
    let(:user)        { Factory(:email_confirmed_user) }

    before do
      sign_in_as(user)
    end

    context "when signed in with a tree" do
      let(:user) { Factory(:email_confirmed_user) }
      let(:tree) do
        tree = Factory(:master_tree)
        Factory(:node, :tree => tree)
        tree
      end
      let(:nodes) { tree.nodes }

      before do
        sign_in_as(user)

        controller.stubs(:current_user => user)
        user_trees = [tree]
        user.stubs(:master_trees => user_trees)
        user_trees.stubs(:find => tree)
        tree.stubs(:children_of => nodes)
      end

      subject { controller }

      context "on GET to #index.json for a given parent_id" do
        before do
          @parent_id = 12345
          @json      = '{}'
          @tree_id   = 456
          NodeJsonPresenter.stubs(:present => @json)
          get :index, :master_tree_id => @tree_id, :format => 'json', :parent_id => @parent_id
        end

        it { should respond_with(:success) }

        it "should render the root node json with the NodeJsonPresenter" do
          tree.should have_received(:children_of).with(@parent_id)
          NodeJsonPresenter.should have_received(:present).with(nodes)
          response.body.should == @json
        end
      end

    end
  end
end

describe NodesController, 'POST to create a node' do
  subject { controller }
  let(:user) { Factory(:email_confirmed_user) }
  let(:tree) do
    tree = Factory(:master_tree)
    Factory(:node, :tree => tree)
    tree
  end
  let(:nodes) { tree.nodes }
  let(:node_attributes) do
    name = Factory(:name, :name_string => "My new node")
    { :name => name }
  end
  let(:new_node) { Factory.build(:node, node_attributes) }

  before do
    sign_in_as(user)
    controller.stubs(:current_user => user)
    user_trees = [tree]
    user.stubs(:master_trees => user_trees)
    user_trees.stubs(:find => tree)
    tree.stubs(:children_of => nodes)
    ::Node.stubs(:new => new_node)
    new_node.stubs(:save => true)
    @node_count = ::Node.count
    r = Resque::Worker.new(Gnite::Config.action_queue)
    post :create, :master_tree_id => tree.id, :format => 'json', :node => { :name => {:name_string => node_attributes[:name].name_string} }, :action_type => 'ActionAddNode'
  end

  it 'creates a new node' do
    (::Node.count - @node_count).should == 1
  end

  it { should respond_with(:success) }

  it 'renders the newly created node as JSON' do
    node = JSON.parse(response.body, :symbolize_names => true)
    node.keys.should == [:node]
  end
end


describe NodesController, 'POST to copy a node from a reference tree' do
  let(:user) { Factory(:email_confirmed_user) }
  let(:master_tree) { Factory(:master_tree, :user => user) }
  let(:parent_node) { Factory(:node, :tree => master_tree) }
  let(:reference_node) do
    child_name = Factory(:name, :name_string => 'child name')
    grandchild_name = Factory(:name, :name_string => 'grandchild_name')
    node = Factory(:node, :tree => Factory(:reference_tree))
    child = Factory(:node, :tree => node.tree, :parent => node, :name => child_name)
    grandchild = Factory(:node, :tree => node.tree, :parent => child, :name => grandchild_name)
    node
  end
  subject { controller }

  before do
    sign_in_as(user)
    @node_count = parent_node.children.size
    post :create, :master_tree_id => master_tree.id, :format => 'json', :node => {:id => reference_node.id, :parent_id => parent_node.id }, :action_type => 'ActionCopyNodeFromAnotherTree'
    @clone_node = ::Node.find(JSON.parse(response.body)['node']['id'])
  end

  it { should respond_with(:success) }

  it 'creates a new node' do
    (parent_node.children.size - @node_count).should == 1
  end

  it 'renders the newly created node as JSON' do
    @clone_node.is_a?(::Node).should be_true
  end

  it 'should create a copy of the reference tree node' do
    @clone_node.name_id.should == reference_node.name_id
    @clone_node.children[0].name_id.should == reference_node.children[0].name_id
    @clone_node.children[0].children[0].name_id.should == reference_node.children[0].children[0].name_id
  end

end


describe NodesController, 'PUT to update' do
  let(:user) { Factory(:email_confirmed_user) }
  let(:tree) { Factory(:master_tree, :user => user) }
  let(:node)  { Factory(:node, :tree => tree) }
  subject { controller }

  before do
    sign_in_as(user)
    put :update,
      :id => node.id,
      :master_tree_id => tree.id,
      :format => 'json',
      :node => (node_attributes rescue nil),
      :action_type => (action_type rescue nil)
  end

  context 'when moving node within tree' do
    let(:new_parent_node) { Factory(:node, :tree => tree) }
    let(:node_attributes) { { :parent_id => new_parent_node.id } }
    let(:action_type) { "ActionMoveNodeWithinTree" }

    it { should respond_with(:success) }

    it "should update the node's parent" do
      node.reload.parent.should == new_parent_node
    end

    it "should render the updated node as JSON" do
      response.body.should == node.reload.to_json
    end
  end

  context "when deleting a node" do
    let(:node_attributes) { { :parent_id => node.parent.id } }
    let(:action_type) { "ActionMoveNodeToDeletedTree" }

    it { should respond_with(:success) }

    it "should move node to deleted tree" do
      node_parent_tree = node.reload.parent.tree
      node_parent_tree.class.should == DeletedTree
      node.parent.should == node_parent_tree.root
    end
  end

  context "when renaming a node" do
    let(:node_attributes) { { :name => { :name_string => 'Updated name' } } }
    let(:action_type) { "ActionRenameNode" }

    it { should respond_with(:success) }

    it "should rename node" do
      node.reload.name.should == Name.find_by_name_string('Updated name')
    end
  end

end

describe NodesController, 'GET to show for master tree' do
  let(:user) { Factory(:email_confirmed_user) }
  let(:node) { Factory(:node, :tree => tree) }
  let(:tree) { Factory(:master_tree, :user => user) }

  subject { controller }

  before do
    sign_in_as(user)

    Factory(:synonym, :node => node, :name => Factory(:name, :name_string => 'Point'))
    Factory(:vernacular_name, :node => node, :name => Factory(:name, :name_string => 'Coordinate'))

    @expected = {
      :rank             => node.rank,
      :synonyms         => ['Point'],
      :vernacular_names => ['Coordinate']
    }

    get :show, :id => node.id, :master_tree_id => tree.id, :format => 'json'
  end

  it { should respond_with(:success) }

  it 'should render synonyms, vernacular names, and rank as JSON' do
    response.body.should == @expected.to_json
  end
end

describe NodesController, 'GET to show for reference tree' do
  let(:user) { Factory(:email_confirmed_user) }
  let(:node) { Factory(:node, :tree => tree) }
  let(:tree) { Factory(:reference_tree) }

  subject { controller }

  before do
    sign_in_as(user)

    Factory(:synonym, :node => node, :name => Factory(:name, :name_string => 'Point'))
    Factory(:vernacular_name, :node => node, :name => Factory(:name, :name_string => 'Coordinate'))

    @expected = {
      :rank             => node.rank,
      :synonyms         => ['Point'],
      :vernacular_names => ['Coordinate']
    }

    get :show, :id => node.id, :reference_tree_id => tree.id, :format => 'json'
  end

  it { should respond_with(:success) }

  it 'should render synonyms, vernacular names, and rank as JSON' do
    response.body.should == @expected.to_json
  end
end
