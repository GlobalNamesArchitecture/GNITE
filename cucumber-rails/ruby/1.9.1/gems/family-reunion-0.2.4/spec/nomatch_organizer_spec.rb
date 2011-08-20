require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FamilyReunion::NomatchOrganizer do
  before(:all) do
    @conf = FamilyReunion::Spec::Config
    @fr = FamilyReunion.new(@conf.ants_primary_node, @conf.ants_secondary_node)
    @no = FamilyReunion::NomatchOrganizer.new(@fr)
    @merges = @conf.matched_merges
  end

  it "should find nonmatched secondary nodes" do
    @fr.stubs(:merges => @merges)
    nomatch_secondary_ids = @no.get_nomach_secondary_ids
    nomatch_secondary_ids.size.should == 10095
    nomatch_secondary_ids.uniq.size.should == nomatch_secondary_ids.size
  end

  it "should be able to assign nomatches to branches in primary node" do
    @fr.stubs(:merges => @merges)
    @no.merge
    @fr.merges.select {|k, v| !v[:nonmatches].empty?}.inject(0) {|res, data| res += data.size; res }.should == 62
  end
end
