require 'spec_helper'

describe TreesController do

  context "signed in" do
    before do
      @user = Factory(:email_confirmed_user)
      sign_in_as(@user)
    end

    context "on GET to #index" do
      let(:trees) { [Factory(:tree)] }

      before do
        controller.stubs(:current_user => @user)
        @user.stubs(:trees => trees)

        get :index
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template(:index) }
      it { should assign_to(:trees).with(trees) }
    end

    context "on a valid GET to #new" do
      let(:tree) { Factory(:tree) }

      before do
        Tree.stubs(:new => tree)
        get :new
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should assign_to(:tree).with(tree) }
      it { should render_template(:new) }
    end

    context "on a valid POST to #create" do
      let(:tree) { Factory(:tree) }

      before do
        Tree.stubs(:new => tree)
        tree.stubs(:save => true)
        post :create
      end

      subject { controller }

      it { should assign_to(:tree).with(tree) }
      it { should redirect_to(tree_url(tree)) }
      it { should set_the_flash.to(/created/) }
    end

    context "on an invalid POST to #create" do
      let(:tree) { Factory(:tree) }

      before do
        Tree.stubs(:new => tree)
        tree.stubs(:save => false)
        post :create
      end

      subject { controller }

      it { should assign_to(:tree).with(tree) }
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end
  end
end
