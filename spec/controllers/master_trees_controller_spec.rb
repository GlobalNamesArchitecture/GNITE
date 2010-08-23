require 'spec_helper'

describe MasterTreesController do

  context "signed in" do
    before do
      @user = Factory(:email_confirmed_user)
      sign_in_as(@user)
    end

    context "on GET to #index" do
      let(:trees) { [Factory(:master_tree)] }

      before do
        controller.stubs(:current_user => @user)
        @user.stubs(:master_trees => trees)

        get :index
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template(:index) }
      it { should assign_to(:trees).with(trees) }
    end

    context "on a valid GET to #new" do
      let(:tree) { Factory(:master_tree) }

      before do
        MasterTree.stubs(:new => tree)
        get :new
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should assign_to(:tree).with(tree) }
      it { should render_template(:new) }
    end

    context "on a valid POST to #create" do
      let(:master_tree) { Factory(:master_tree) }

      before do
        MasterTree.stubs(:new => master_tree)
        master_tree.stubs(:save => true)
        post :create
      end

      subject { controller }

      it "should assign the tree to the current user" do
        assigns(:tree).user.should == @user
      end

      it { should assign_to(:tree).with(master_tree) }
      it { should redirect_to(master_tree_url(master_tree)) }
      it { should set_the_flash.to(/created/) }
    end

    context "on an invalid POST to #create" do
      let(:tree) { Factory(:master_tree) }

      before do
        MasterTree.stubs(:new => tree)
        tree.stubs(:save => false)
        post :create
      end

      subject { controller }

      it { should assign_to(:tree).with(tree) }
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "on a valid GET to #new" do
      let(:tree) { Factory(:master_tree) }

      before do
        get :edit, :id => tree.id
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should assign_to(:tree).with(tree) }
      it { should render_template(:edit) }
    end

    context "on a valid PUT to #upate" do
      let(:tree) { Factory(:master_tree) }

      before do
        MasterTree.stubs(:find => tree)
        tree.stubs(:save => true)
        put :update, :id => tree.id, :tree => {}
      end

      subject { controller }

      it { should assign_to(:tree).with(tree) }
      it { should redirect_to(master_tree_url(tree)) }
      it { should set_the_flash.to(/updated/) }
    end

    context "on an invalid POST to #update" do
      let(:tree) { Factory(:master_tree) }

      before do
        MasterTree.stubs(:find => tree)
        tree.stubs(:save => false)
        put :update, :id => tree.id, :tree => {}
      end

      subject { controller }

      it { should assign_to(:tree).with(tree) }
      it { should_not set_the_flash }
      it { should render_template(:edit) }
    end
  end
end
