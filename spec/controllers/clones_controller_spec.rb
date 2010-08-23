require 'spec_helper'

describe ClonesController do
  context "when signed out" do
    context "on POST to create" do
      before do
        post :create, :master_tree_id => 123, :node_id => 456
      end

      subject { controller }

      it { should redirect_to(sign_in_url) }
      it { should set_the_flash.to(/sign in/) }
    end
  end

  context "signed in with a tree and nodes" do
    let(:user)        { Factory(:email_confirmed_user) }

    before do
      sign_in_as(user)
    end

    context "on successful POST to #create with a master_tree_id, node_id, and a new parent_id" do
      before do
        controller.stubs(:current_user => user)

        @clone = stub('clone', :save  => true, :attributes= => true, :to_json => 'json')
        @node  = stub('node',  :deep_copy => @clone, :id => 456)
        @nodes = stub('nodes', :find  => @node)
        @tree  = stub('master_tree',  :nodes => @nodes, :id => 123)
        @trees = stub('master_trees', :find => @tree)
        user.stubs(:master_trees => @trees)

        @new_attributes = { 'parent_id' => 'new_parent_id' }

        post :create,
             :master_tree_id => @tree.id,
             :node_id => @node.id,
             :node => @new_attributes
      end

      subject { controller }

      it { should respond_with(:created) }

      it "should render the newly created node as JSON" do
        response.body.should == @clone.to_json
      end

      it "should find trees on the current user" do
        user.should have_received(:master_trees).with()
        @trees.should have_received(:find).with(@tree.id)
      end

      it "should find the specified node on the specified tree" do
        @tree.should have_received(:nodes).with()
        @nodes.should have_received(:find).with(@node.id)
      end

      it "should clone the requested node" do
        @node.should have_received(:deep_copy).with()
      end

      it "should apply the specified attributes to the clone" do
        @clone.should have_received(:attributes=).with(@new_attributes)
      end

      it "should save the new clone" do
        @clone.should have_received(:save).with()
      end
    end
  end

end
