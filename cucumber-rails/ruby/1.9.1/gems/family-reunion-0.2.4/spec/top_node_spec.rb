require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FamilyReunion::TopNode do
  before(:all) do
    @conf = FamilyReunion::Spec::Config
    @node = FamilyReunion::TopNode.new(@conf.ants_primary_node)
  end

  it "should get hash with ids as keys for valid names" do
    res = @node.ids_hash
    res.size.should == 97
    res[:'invasiveants:tid:1489'].is_a?(Hash).should be_true
  end

  it "should return path hash" do
    res = @node.paths_hash
    res.is_a?(Hash).should be_true
    res[:Linepithema].should == [[:Formicidae, :Linepithema], [:"invasiveants:tid:1381", :"invasiveants:tid:1425"]]
  end

  it "should return root paths" do
    @node.root_paths.should == [["Formicidae"], [:"invasiveants:tid:1381"]]
  end

end

