require 'spec_helper'

describe MasterTreesController do
  context "signed in" do
    before do
      @user = Factory(:user)
      sign_in @user
    end

    context "on GET to #index" do
      let(:trees) { [Factory(:master_tree)] }

      before do
        controller.stubs(:current_user => @user)
        @user.stubs(:master_trees => trees)
        trees.stubs(:by_title => trees)

        get :index
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template(:index) }

      it "should assign_to(:master_trees).with(trees)" do
        assigns(:master_trees).should == trees
      end

      it 'sorts the tress by title' do
        trees.should have_received(:by_title)
      end
    end

    context "on a valid GET to #new" do
      let(:master_tree) { Factory(:master_tree) }

      before do
        MasterTree.stubs(:new => master_tree)
        master_tree.stubs(:save => true)
        get :new
      end

      subject { controller }

      it "should assign the tree to the current user" do
        assigns(:master_tree).user.should == @user
      end

      it "should assign_to(:master_tree).with(master_tree)" do
        assigns(:master_tree).should == master_tree
      end
      
      it { should redirect_to(master_tree_url(master_tree)) }
    end

    context "on a valid GET to #new" do
      let(:tree) { Factory(:master_tree) }

      before do
        get :edit, :id => tree.id
      end

      subject { controller }

      it { should respond_with(:success) }

      it "should assign_to(:master_tree).with(tree)" do
        assigns(:master_tree).should == tree
      end
      
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

      it "should assign_to(:master_tree).with(tree)" do
        assigns(:master_tree).should == tree
      end

      it { should redirect_to(master_tree_url(tree)) }
      it { should set_the_flash.to(/updated/) }
    end

    context "on an invalid POST to #update" do
      let(:tree) { Factory(:master_tree) }

      before do
        MasterTree.stubs(:find => tree)
        tree.stubs(:save => false)
        put :update, :id => tree.id, :master_tree => {}
      end

      subject { controller }

      it "should assign_to(:master_tree).with(tree)" do
        assigns(:master_tree).should == tree
      end

      it { should_not set_the_flash }
      it { should render_template(:edit) }
    end
  end
end

describe MasterTreesController, 'GET index without authenticating' do
  before { get :index }
  it     { should redirect_to(new_user_session_url) }
end

describe MasterTreesController, 'GET new without authenticating' do
  before { get :new }
  it     { should redirect_to(new_user_session_url) }
end

describe MasterTreesController, 'GET show without authenticating' do
  before { get :show, :id => 1 }
  it     { should redirect_to(new_user_session_url) }
end

describe MasterTreesController, 'GET edit without authenticating' do
  before { get :edit, :id => 1 }
  it     { should redirect_to(new_user_session_url) }
end

describe MasterTreesController, 'PUT update without authenticating' do
  before { put :update, :id => 1 }
  it     { should redirect_to(new_user_session_url) }
end
