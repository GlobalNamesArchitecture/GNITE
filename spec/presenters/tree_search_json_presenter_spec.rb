require 'spec_helper'

describe TreeSearchJsonPresenter do
  it "should present tree search results as JSON" do
    node = Factory(:node, :name => Factory(:name, :name_string => 'node-name'))
    nodes = [node]

    expected_hash = [{"name"=>"node-name", "id"=> node.id, "treepath"=>{"name_strings"=>"node-name", "node_ids"=>["#" + node.id.to_s]}}]
    presented_hash = JSON.parse(TreeSearchJsonPresenter.present(nodes))

    presented_hash.should == expected_hash
  end
end