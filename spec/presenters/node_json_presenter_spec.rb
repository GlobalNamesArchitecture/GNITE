require 'spec_helper'

describe NodeJsonPresenter do
  it "should present nodes as JSON" do
    node = Factory(:node, :name => 'node-name')
    nodes = [node]

    expected_hash = [{"attr" => { "id" => node.id}, "data" => "node-name"}]
    presented_hash = JSON.parse(NodeJsonPresenter.present(nodes))

    presented_hash.should == expected_hash
  end

  it "should render nodes with a 'closed' state when they have children" do
    parent = Factory(:node, :name => 'parent')
    child  = Factory(:node, :name => 'child', :parent => parent)
    nodes  = [parent]

    expected_hash = [
      {
        "attr" => { "id" => parent.id },
        "data" => "parent",
        "state" => "closed"
      }
    ]

    presented_hash = JSON.parse(NodeJsonPresenter.present(nodes))
    presented_hash.should == expected_hash
  end

end
