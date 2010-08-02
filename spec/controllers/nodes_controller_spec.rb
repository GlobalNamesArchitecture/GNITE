require 'spec_helper'

describe NodesController do

  context "when signed in with a tree" do
    let(:user) { Factory(:email_confirmed_user) }
    let(:tree) { Factory(:tree, :user => user) }
    let(:node) { Factory(:node, :tree => tree) }
    let(:nodes) { [node] }

    before do
      sign_in_as(user)

      controller.stubs(:current_user => user)
      user_trees = [tree]
      user.stubs(:trees => user_trees)
      user_trees.stubs(:find => tree)
    end

    subject { controller }

    context "on GET to #index.json" do
      before do
        tree.stubs(:nodes => nodes)

        get :index, :tree_id => tree.id, :format => 'json'
      end


      it { should respond_with(:success) }

      it "should render the node json" do
        expected_node_structure = [
          {
            :data => node.name,
            :attr => {
              :id => node.id
            }
          }
        ]

        response.body.should == expected_node_structure.to_json
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
