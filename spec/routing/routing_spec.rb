require 'spec/spec_helper'

describe "routing to master_trees" do
  it "routes /master_trees to master_trees#index" do
    { :get => "/master_trees" }.should route_to(
      :controller => "master_trees",
      :action => "index"
    )
  end
  it "routes /master_trees/new to master_trees#new" do
    { :get => "master_trees/new" }.should route_to(
      :controller => "master_trees",
      :action => "new"
    )
  end
  it "routes /master_trees to master_trees#create" do
    { :post => "/master_trees" }.should route_to(
      :controller => "master_trees",
      :action => "create"
    )
  end
  it "routes /master_trees/abc to master_trees#show" do
    { :get => "/master_trees/abc" }.should route_to(
      :controller => "master_trees",
      :action => "show",
      :id => "abc"
    )
  end
  it "routes /master_trees/abc/edit to master_trees#edit" do
    { :get => "/master_trees/abc/edit" }.should route_to(
      :controller => "master_trees",
      :action => "edit",
      :id => "abc"
    )
  end
    it "routes /master_trees/abc to master_trees#update" do
    { :put => "/master_trees/abc" }.should route_to(
      :controller => "master_trees",
      :action => "update",
      :id => "abc"
    )
  end

end

describe "routing to users" do
  it "routes /users/abc/edit to users#edit" do
    { :get => "/users/abc/edit" }.should route_to(
      :controller => "users",
      :action => "edit",
      :id => "abc"
    )
  end
  it "routes /users/abc to users#update" do
    { :put => "/users/abc" }.should route_to(
      :controller => "users",
      :action => "update",
      :id => "abc"
    )
  end
end

describe "routing to passwords" do
  it "routes /your/password/edit to passwords#edit" do
    { :get => "/your/password/edit" }.should route_to(
      :controller => "your/passwords",
      :action => "edit"
    )
  end
end

describe "routing to nodes" do
  it "routes /master_trees/:id/nodes.json to nodes#index" do
    { :get => "/master_trees/123/nodes.json" }.should route_to(
      :controller => "nodes",
      :action     => "index",
      :master_tree_id    => "123",
      :format     => "json"
    )
  end

  it "routes POST /master_trees/:id/nodes.json to nodes#create" do
    { :post => "/master_trees/123/nodes.json" }.should route_to(
      :controller => "nodes",
      :action     => "create",
      :master_tree_id    => "123",
      :format     => "json"
    )
  end
  it "routes PUT /master_trees/:master_tree_id/nodes/:id.json to nodes#update" do
    { :put => "/master_trees/123/nodes/abc.json" }.should route_to(
      :controller => "nodes",
      :action     => "update",
      :master_tree_id    => "123",
      :id         => "abc",
      :format     => "json"
    )
  end
  it "routes DELETE /master_trees/:master_tree_id/nodes/:id.json to nodes#delete" do
    { :delete => "/master_trees/123/nodes/abc.json" }.should route_to(
      :controller => "nodes",
      :action     => "destroy",
      :master_tree_id    => "123",
      :id         => "abc",
      :format     => "json"
    )
  end

  it "routes POST /master_trees/:master_tree_id/nodes/:id/clone.json to nodes/clones#create" do
    { :post => "/master_trees/123/nodes/456/clone.json" }.should route_to(
      :controller => "clones",
      :action     => "create",
      :master_tree_id    => "123",
      :node_id         => "456",
      :format     => "json"
    )
  end
end

describe "sign_up, sign_in, sign_out" do
  it "route /sign_up to users#new" do
    { :get => "/sign_up" }.should route_to(
      :controller => 'users',
      :action => 'new'
    )
  end
  it "route /sign_in to sessions#new" do
    { :get => "/sign_in" }.should route_to(
      :controller => 'sessions',
      :action => 'new'
    )
  end
  it "route /sign_out to sessions#destroy" do
    { :get => "/sign_out" }.should route_to(
      :controller => 'sessions',
      :action => 'destroy'
    )
  end
end
