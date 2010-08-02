require 'spec/spec_helper'

describe "routing to trees" do
  it "routes /trees to trees#index" do
    { :get => "/trees" }.should route_to(
      :controller => "trees",
      :action => "index"
    )
  end
  it "routes /trees/new to trees#new" do
    { :get => "trees/new" }.should route_to(
      :controller => "trees",
      :action => "new"
    )
  end
  it "routes /trees to trees#create" do
    { :post => "/trees" }.should route_to(
      :controller => "trees",
      :action => "create"
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
  it "routes /trees/:id/nodes.json to nodes#index" do
    { :get => "/trees/123/nodes.json" }.should route_to(
      :controller => "nodes",
      :action     => "index",
      :tree_id    => "123",
      :format     => "json"
    )
  end
end
