require 'spec_helper'

describe NodesController do

  context "when signed in with a tree" do
    let(:user) { Factory(:email_confirmed_user) }
    let(:tree) { Factory(:tree, :user => user) }
    let(:node) { Factory(:node, :tree => tree) }
    let(:nodes) { [node] }

    before do
      sign_in_as(user)
    end

    context "on GET to #index.json" do
      before do
        controller.stubs(:current_user => user)
        user_trees = [tree]
        user.stubs(:trees => user_trees)
        user_trees.stubs(:find => tree)
        tree.stubs(:nodes => nodes)

        get :index, :tree_id => tree.id, :format => 'json'
      end

      subject { controller }

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
  end

end
