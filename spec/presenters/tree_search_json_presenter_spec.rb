require 'spec_helper'

describe TreeSearchJsonPresenter do
  it "should present tree search results as JSON" do
    parent = Factory(:node, :name => Factory(:name, :name_string => 'parent'))
    child = Factory(:node, :parent => parent, :name => Factory(:name, :name_string => 'child'))
    nodes = [child] #simulate search for child name

    expected_hash = [{"name" => "child", "id" => child.id, "treepath" => { "name_strings" => "parent > child", "node_ids"=>["#" + parent.id.to_s, "#" + child.id.to_s] } } ]
    presented_hash = JSON.parse(TreeSearchJsonPresenter.present(nodes))

    presented_hash.should == expected_hash
  end
end