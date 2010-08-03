require 'spec_helper'

describe Node do
  it { should belong_to :tree }
  it { should validate_presence_of :tree_id }
  it { should validate_presence_of :name }

  it "should support constructing a hierarchy" do
    root = Factory(:node)
    child = Factory(:node, :parent => root)
    grandchild = Factory(:node, :parent => child)

    root.children.should == [child]
    grandchild.parent.parent.should == root
  end
end
