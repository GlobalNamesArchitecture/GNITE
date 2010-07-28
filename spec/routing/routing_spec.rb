require 'spec/spec_helper'

describe "routing to trees" do
  it "routes /trees to trees#index" do
    { :get => "/trees" }.should route_to(
      :controller => "trees",
      :action => "index"
    )
  end

  it "routes /your/password/edit to passwords#edit" do
    { :get => "/your/password/edit" }.should route_to(
      :controller => "your/passwords",
      :action => "edit"
    )
  end
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
