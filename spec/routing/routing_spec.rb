require 'spec/spec_helper'

describe "routing to trees" do
  it "routes /trees to trees#index" do
    { :get => "/trees" }.should route_to(
      :controller => "trees",
      :action => "index"
    )
  end
end
