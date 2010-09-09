require 'spec_helper'

describe NodesController do

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

    context "on POST to create" do
      let(:node_attributes) do
        { :name => "My new node" }
      end

      let(:new_node) { Factory.build(:node, node_attributes) }

      before do
        Node.stubs(:new => new_node)
        new_node.stubs(:save => true)

        post :create, :master_tree_id => tree.id, :format => 'json', :node => node_attributes
      end

      it "should create a new node" do
        Node.should have_received(:new).with(node_attributes.merge({
          :tree_id => tree.id
        }).stringify_keys)

        new_node.should have_received(:save)
      end

      it { should respond_with(:success) }

      it "should render the newly created node as JSON" do
        response.body.should == new_node.to_json
      end
    end

    context "on PUT to update" do
      let(:node_attributes) do
        { :name => "My renamed node" }
      end
      let(:node) { Factory(:node, node_attributes) }

      before do
        Node.stubs(:find => node)
        node.stubs(:update_attributes => node)
        node.stubs(:save => true)
        put :update, :id => node.id, :master_tree_id => node.tree.id, :format => 'json', :node => node_attributes
      end

      it "should find and update a node" do
        Node.should have_received(:find).with(node.id)
        node.should have_received(:update_attributes).with(node_attributes.merge({ :tree_id => node.tree.id }).stringify_keys)

        node.should have_received(:save)
      end

      it { should respond_with(:success) }

      it "should render the updated node as JSON" do
        response.body.should == node.to_json
      end
    end

    context "on DELETE to destroy" do
      let(:node) { Factory(:node) }
      before do
        Node.stubs(:destroy)
        delete :destroy, :id => node.id, :master_tree_id => node.tree.id, :format => 'json'
      end

      it { should respond_with(:success) }

      it "should delete the node" do
        Node.should have_received(:destroy).with(node.id)
      end

    end

  end
end
