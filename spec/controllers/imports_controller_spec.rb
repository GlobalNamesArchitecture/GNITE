require 'spec_helper'

describe ImportsController do
  context "when signed out" do
    context "on GET to new" do
      before do
        get :new, :master_tree_id => 123
      end

      subject { controller }

      it { should redirect_to(sign_in_url) }
      it { should set_the_flash.to(/sign in/) }
    end
  end

  context "signed in" do
    let(:user) { Factory(:email_confirmed_user) }

    before do
      sign_in_as(user)
      controller.stubs(:current_user => user)
    end

    context "GET to #new with a master_tree_id" do
      let(:master_tree)  { Factory(:master_tree, :user => user) }
      let(:master_trees) { [master_tree] }

      before do
        user.stubs(:master_trees => master_trees)
        master_trees.stubs(:find => master_tree)
        get :new, :master_tree_id => master_tree.to_param
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template('new') }

      it 'should assign_to(:master_tree).with(master_tree)' do
        assigns(:master_tree).should == master_tree
      end

      it "should find the correct master tree" do
        user.should have_received(:master_trees).with()
        master_trees.should have_received(:find).with(master_tree.to_param)
      end
    end
  end
end
