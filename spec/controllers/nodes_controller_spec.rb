require 'spec_helper'

describe NodesController do

  context "when signed in with a tree" do
    let(:user) { Factory(:email_confirmed_user) }
    let(:tree) do
      tree = Factory(:tree)
      Factory(:node, :tree => tree)
      tree
    end
    let(:nodes) { tree.nodes }

    before do
      sign_in_as(user)

      controller.stubs(:current_user => user)
      user_trees = [tree]
      user.stubs(:trees => user_trees)
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
        get :index, :tree_id => @tree_id, :format => 'json', :parent_id => @parent_id
      end

      it { should respond_with(:success) }

      it "should render the root node json with the NodeJsonPresenter" do
        tree.should have_received(:children_of).with(@parent_id)
        NodeJsonPresenter.should have_received(:present).with(nodes)
        response.body.should == @json
      end
    end

    context "on POST to create" do
      let(:node_attributes) do
        { :name => "My new node" }
      end

      let(:new_node) { Factory.build(:node, node_attributes) }

      before do
        Node.stubs(:new => new_node)
        new_node.stubs(:save => true)

        post :create, :tree_id => tree.id, :format => 'json', :node => node_attributes
      end

      it "should create a new node" do
        Node.should have_received(:new).with(node_attributes.merge({
          :tree_id => tree.id
        }).stringify_keys)

        new_node.should have_received(:save)
      end

      it { should respond_with(:created) }

      it "should render the newly created node as JSON" do
        response.body.should == new_node.to_json
      end
    end
  end

end
