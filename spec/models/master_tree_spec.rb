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
  it { should have_many(:reference_tree_collections) }
  it { should have_many(:reference_trees).through(:reference_tree_collections) }

  it "should get deleted tree upon creation" do
    tree = Factory(:master_tree)
    deleted_names = DeletedTree.where(:master_tree_id => tree.id)
    deleted_names.size.should == 1
    deleted_names[0].title.should == "Deleted Names"
  end

  describe "#create_darwin_core_archive" do

    it "should have publish method" do
      @master_tree.respond_to?(:create_darwin_core_archive).should be_true
    end

    it "should create a valid dwc_archive in tmp directory" do
      MasterTreeContributor.create!(:master_tree => @master_tree, :user => Factory(:user))
      dwc_file = File.join(::Rails.root.to_s, 'tmp', "#{@master_tree.uuid}.tar.gz")
      FileUtils.rm(dwc_file) if File.exists?(dwc_file)
      File.exists?(dwc_file).should be_false
      @master_tree.create_darwin_core_archive
      File.exists?(dwc_file).should be_true
      d = DarwinCore.new(dwc_file)
      d.archive.valid?.should be_true
      d.metadata.authors.size.should == 2
    end

  end

end

describe MasterTree, 'finding in sorted by title' do
  let(:user) { Factory(:email_confirmed_user) }
  let(:z_tree) { Factory(:master_tree, :title => 'z', :user => user) }
  let(:b_tree) { Factory(:master_tree, :title => 'b', :user => user) }
  let(:a_tree) { Factory(:master_tree, :title => 'a', :user => user) }

  it 'finds the trees in ascending title order' do
    user.master_trees.by_title.should == [a_tree, b_tree, z_tree]
  end
end



