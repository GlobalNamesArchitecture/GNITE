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
    let(:node)        { Factory(:node, :tree => Factory(:reference_tree, :user => user)) }
    let(:clone)       { Factory(:node, :tree => master_tree) }
    let(:parent)      { Factory(:node, :tree => master_tree) }
    let(:master_tree) { Factory(:master_tree, :user => user) }

    before do
      sign_in_as(user)
    end

    context "on successful POST to #create with a master_tree_id, node_id, and a new parent_id" do
      subject { controller }

      before do
        clone.stubs(:save)
        clone.stubs(:attributes=)
        node.stubs(:deep_copy_to).with(master_tree).returns(clone)
        Node.stubs(:find_by_id_for_user).with(node.id, user).returns(node)

        @new_attributes = { 'parent_id' => parent.id }

        post :create,
             :master_tree_id  => master_tree.id,
             :node_id         => node.id,
             :node            => @new_attributes
      end

      it { should respond_with(:success) }

      it "should render the newly created node as JSON" do
        response.body.should == clone.to_json
      end

      it "should find the specified node scoped under the current user" do
        Node.should have_received(:find_by_id_for_user).with(node.id, user)
      end

      it "should clone the requested node" do
        node.should have_received(:deep_copy_to).with(master_tree)
      end

      it "should apply the specified attributes to the clone" do
        clone.should have_received(:attributes=).with(@new_attributes)
      end

      it "should save the new clone" do
        clone.should have_received(:save).with()
      end
    end
  end

end
