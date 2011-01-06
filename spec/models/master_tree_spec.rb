require 'spec_helper'

describe MasterTree do
  
  before(:all) do
    @master_tree = Factory(:master_tree, :abstract => "It is my tree of very strange taxa")
    @root = Factory(:node, :tree => @master_tree)
    5.times { Factory(:node, :parent => @root, :tree => @master_tree) }
    @master_tree.children_of(@root).each do |child|
      5.times { Factory(:node, :parent => child, :tree => @master_tree) }
    end
  end

  it { should be_kind_of(Tree) }
  it { should have_many(:reference_trees) }
  
  describe "#create_darwin_core_archive" do
    
    it "should have publish method" do
      @master_tree.respond_to?(:create_darwin_core_archive).should be_true
    end

    it "should create a valid dwc_archive in tmp directory" do
      dwc_file = File.join(::Rails.root.to_s, 'tmp', "#{@master_tree.uuid}.tar.gz")
      FileUtils.rm(dwc_file) if File.exists?(dwc_file)
      File.exists?(dwc_file).should be_false
      @master_tree.create_darwin_core_archive
      File.exists?(dwc_file).should be_true
      d = DarwinCore.new(dwc_file)
      d.archive.valid?.should be_true
    end

  end

end
