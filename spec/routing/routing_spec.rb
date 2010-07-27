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
end
