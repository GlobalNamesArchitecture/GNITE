require "spec_helper"

describe GnaclrPublisher do

  before(:all) do
    @master_tree = create(:master_tree, abstract: "It is my tree of very strange taxa")
    root = create(:node, tree: @master_tree)
    5.times { create(:node, parent: root, tree: @master_tree) }
    @master_tree.children_of(root).each do |child|
      5.times { create(:node, parent: child, tree: @master_tree) }
    end
    @gp = GnaclrPublisher.create(master_tree: @master_tree)
  end

  it "should have master tree" do
    @master_tree.should_not be_nil
  end

  describe "#create" do
    it "should have master tree" do
      @master_tree.should_not be_nil
      @gp.master_tree.should_not be_nil
      @gp.master_tree.should == @master_tree
    end
  end

  describe '#publish' do
    it "should create dwca file" do
      RestClient.stubs(post: nil)
      file = File.join(Rails.root.to_s, 'tmp', "#{@master_tree.uuid}.tar.gz")
      FileUtils.rm(file) if File.exists?(file)
      File.exists?(file).should be_falsey
      @gp.publish
      File.exists?(file).should be_truthy
      RestClient.should have_received(:post)
    end
  end
end
