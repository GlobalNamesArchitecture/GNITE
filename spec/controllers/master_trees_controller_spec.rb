require 'spec_helper'

describe MasterTreesController do
  context "signed in" do
    before do
      @user = create(:user)
      sign_in @user
    end

    context "on GET to #index" do
      let(:tree) { create(:master_tree, user_id: @user.id) }

      before do
        controller.stubs(current_user: @user)
        tree.stubs(save: true)
        get :index
      end

      subject { controller }

      it { should respond_with(:success) }
      it { should render_template(:index) }

    end

    context "on a valid GET to #new" do
      let(:master_tree) { create(:master_tree, user_id: @user.id) }

      before do
        MasterTree.stubs(new: master_tree)
        master_tree.stubs(save: true)
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
      let(:tree) { create(:master_tree, user_id: @user.id) }

      before do
        get :edit, id: tree.id
      end

      subject { controller }

      it { should respond_with(:success) }

      it "should assign_to(:master_tree).with(tree)" do
        assigns(:master_tree).should == tree
      end
      
      it { should render_template(:edit) }
    end

    context "on a valid PUT to #update" do
      let(:tree) { create(:master_tree, user_id: @user.id) }

      before do
        MasterTree.stubs(find: tree)
        tree.stubs(save: true)
        put :update, id: tree.id, tree: {}
      end

      subject { controller }

      it { should render_template(:edit) }
      it { should set_the_flash.to(/updated/) }
    end

    context "on a valid PUT to #upate without permission" do
      let(:tree) { create(:master_tree, user: @user) }

      before do
        MasterTree.stubs(find: tree)
        tree.stubs(save: true)
        put :update, id: tree.id, tree: {}
      end

      subject { controller }

      it { should redirect_to(root_url) }
      it { should set_the_flash.to(/denied/) }
    end

    context "on a valid POST to #update" do
      let(:tree) { create(:master_tree, user_id: @user.id) }

      before do
        MasterTree.stubs(find: tree)
        tree.stubs(save: true)
        post :update, id: tree.id, master_tree: {}
      end

      subject { controller }

      it "should assign_to(:master_tree).with(tree)" do
        assigns(:master_tree).should == tree
      end

      it { should set_the_flash.to(/updated/) }
      it { should render_template(:edit) }
    end
    
    context "on a valid POST to #update without permission" do
      let(:tree) { create(:master_tree, user: @user) }

      before do
        MasterTree.stubs(find: tree)
        tree.stubs(save: true)
        post :update, id: tree.id, master_tree: {}
      end

      subject { controller }

      it { should set_the_flash.to(/denied/) }
      it { should redirect_to(root_url) }
    end
    
    context "on a valid DELETE to #destroy" do
      let(:tree) { create(:master_tree, user_id: @user.id) }
      
      before do
        delete :destroy, id: tree.id
      end
      
      subject { controller }
      
      it { should set_the_flash.to(/deleted/) }
      it { should redirect_to(master_trees_url) }
    end
    
    context "on a valid DELETE to #destroy without permission" do
      let(:tree) { create(:master_tree, user: @user) }
      
      before do
        delete :destroy, id: tree.id
      end
      
      subject { controller }
      
      it { should set_the_flash.to(/denied/) }
      it { should redirect_to(root_url) }
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
  before { get :show, id: 1 }
  it     { should redirect_to(new_user_session_url) }
end

describe MasterTreesController, 'GET edit without authenticating' do
  before { get :edit, id: 1 }
  it     { should redirect_to(new_user_session_url) }
end

describe MasterTreesController, 'PUT update without authenticating' do
  before { put :update, id: 1 }
  it     { should redirect_to(new_user_session_url) }
end

describe MasterTreesController, 'DELETE destroy without authenticating' do
  before { delete :destroy, id: 1 }
  it     { should redirect_to(new_user_session_url) }
end
