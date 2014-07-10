require 'spec_helper'

describe BookmarksController, 'GET to show bookmarks for master tree' do
  let(:user) { create(:user) }
  let(:master_tree) { create(:master_tree, user_id: user.id) }
  let(:node)  { create(:node, tree: master_tree) }
  let(:bookmark) { create(:bookmark, node: node, bookmark_title: "My new bookmark") }
  
  subject { controller }

  before do
    sign_in user
    get :index, master_tree_id: master_tree
  end
    
  it { should respond_with(:success) }
  it { should render_template(:bookmark) }
end

describe BookmarksController, 'POST to create bookmark in master tree' do
  let(:user) { create(:user) }
  let(:master_tree) { create(:master_tree, user_id: user.id) }
  let(:node)  { create(:node, tree: master_tree) }

  subject { controller }

  before do
    sign_in user
    @bookmark_count = Bookmark.count
    post :create, master_tree_id: master_tree, id: node.id, bookmark_title: "My bookmark", format: 'json'
    @clone_bookmark = Bookmark.find(JSON.parse(response.body)['bookmark']['id'])
  end
  
  it 'creates a new bookmark' do
    (Bookmark.count - @bookmark_count).should == 1
  end
  
  it { should respond_with(:success) }

  it 'deletes the new bookmark' do
    @bookmark_count = Bookmark.count
    delete :destroy, master_tree_id: master_tree, id: @clone_bookmark.id, format: 'json'
    Bookmark.count.should == 0
  end
  
  it { should respond_with(:success) }
end

describe BookmarksController, 'PUT to update a bookmark in master tree' do
  let(:user) { create(:user) }
  let(:master_tree) { create(:master_tree, user_id: user.id) }
  let(:node) { create(:node, tree: master_tree) }
  let(:bookmark) { create(:bookmark, node: node) }
  
  subject { controller }
  
  before do
    sign_in user
    put :update, master_tree_id: master_tree, id: bookmark, bookmark_title: "My bookmark", format: 'json'
    updated_bookmark = JSON.parse(response.body)
    updated_bookmark.first["bookmark"]["title"].should == "My bookmark"
  end
end

describe BookmarksController, 'GET to show bookmarks for reference tree' do
  let(:user) { create(:user) }
  let(:reference_tree) { create(:reference_tree) }
  let(:node)  { create(:node, tree: reference_tree) }
  let(:nodes) { reference_tree.nodes }

  subject { controller }

  before do
    sign_in user
    create(:bookmark, node: node, bookmark_title: "My new bookmark")
    get :index, reference_tree_id: reference_tree
  end
  
  it { should respond_with(:success) }
  it { should render_template(:bookmark) }
  
end

describe BookmarksController, 'POST to create bookmark in reference tree' do
  let(:user) { create(:user) }
  let(:reference_tree) { create(:reference_tree) }
  let(:node)  { create(:node, tree: reference_tree) }

  subject { controller }

  before do
    sign_in user
    @bookmark_count = Bookmark.count
    post :create, reference_tree_id: reference_tree, id: node.id, bookmark_title: "My bookmark", format: 'json'
    @clone_bookmark = Bookmark.find(JSON.parse(response.body)['bookmark']['id'])
  end
  
  it 'creates a new bookmark' do
    (Bookmark.count - @bookmark_count).should == 1
  end
  
  it { should respond_with(:success) }
  
  it 'deletes the new bookmark' do
    @bookmark_count = Bookmark.count
    delete :destroy, reference_tree_id: reference_tree, id: @clone_bookmark.id, format: 'json'
    Bookmark.count.should == 0
  end
  
  it { should respond_with(:success) }
end

describe BookmarksController, 'PUT to update a bookmark in reference tree' do
  let(:user) { create(:user) }
  let(:reference_tree) { create(:reference_tree) }
  let(:node) { create(:node, tree: reference_tree) }
  let(:bookmark) { create(:bookmark, node: node) }
  
  subject { controller }
  
  before do
    sign_in user
    put :update, reference_tree_id: reference_tree, id: bookmark, bookmark_title: "My bookmark", format: 'json'
    updated_bookmark = JSON.parse(response.body)
    updated_bookmark.first["bookmark"]["title"].should == "My bookmark"
  end
end

describe BookmarksController, 'GET index in master tree without authenticating' do
  before { get :index, master_tree_id: 123 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end

describe BookmarksController, 'POST create in master tree without authenticating' do
  before { post :create, master_tree_id: 123, id: 45 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end

describe BookmarksController, 'PUT in master tree without authenticating' do
  before { put :update, master_tree_id: 123, id: 45 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end

describe BookmarksController, 'DELETE delete in master tree without authenticating' do
  before { delete :destroy, master_tree_id: 123, id: 45 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end

describe BookmarksController, 'GET index in reference tree without authenticating' do
  before { get :index, reference_tree_id: 123 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end

describe BookmarksController, 'POST create in reference tree without authenticating' do
  before { post :create, reference_tree_id: 123, id: 45 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end

describe BookmarksController, 'PUT update in reference tree without authenticating' do
  before { put :update, reference_tree_id: 123, id: 45 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end

describe BookmarksController, 'DELETE delete in reference tree without authenticating' do
  before { delete :destroy, reference_tree_id: 123, id: 45 }
  it     { should redirect_to(new_user_session_url) }
  it     { should set_the_flash.to(/sign in/) }
end