require 'spec_helper'

describe JobsLog do
  before(:all) do
    @tree = create(:reference_tree)
    @an_object_id = 333
    @gnaclr_importer = create(:gnaclr_importer, reference_tree: @tree, status: 'test')
    @logger = JobsLogger.new
  end

  describe "#subscribe" do
    it "should create subscription" do
      @logger.subscribe(job_type: "GnaclrImporter", an_object_id: @an_object_id, tree_id: @tree.id)
      @logger.subscriptions[@an_object_id][:tree_id].should == @tree.id
    end
  end

  describe "#unsubscribe" do
    it "should remove subscription" do
      @logger.subscribe(job_type: "GnaclrImporter", an_object_id: @an_object_id, tree_id: @tree.id)
      @logger.subscriptions[@an_object_id].should == {:tree_id=> @tree.id, :job_type=>"GnaclrImporter"}
      @logger.unsubscribe(@an_object_id)
      @logger.subscriptions[@an_object_id].should be_nil
    end
  end

  describe "#info" do
    before(:each) do
      @logger.subscribe(an_object_id: @an_object_id, tree_id: @tree.id, job_type: 'GnaclrImporter')
    end

    it 'should ignore logs that do not have pipe delimited object_id and message' do
      count = JobsLog.count
      @logger.info('wrong kind of string')
      JobsLog.count.should == count
    end

    it 'should take a pipe delimited string, split it on object_id and a message, and saves a row in a log table' do
      count = JobsLog.count
      @logger.info("|#{@an_object_id}|my message|")
      JobsLog.count.should == count + 1
      jl = JobsLog.last
      jl.tree.id.should == @tree.id
      jl.message.should == 'my message'
    end

    it 'should ignore messages belogning to unsubscribed trees' do
      @logger.unsubscribe(@an_object_id)
      count = JobsLog.count
      @logger.info("|#{@an_object_id}|my message|")
      JobsLog.count.should == count
    end

    it 'should ignore logs with unknown dwc_object_ids' do
      count = JobsLog.count
      @logger.info("|123|my message|")
      JobsLog.count.should == count
    end

  end

end
