require 'spec_helper'

describe GnaclrImporterLogger do
  before(:all) do
    user = Factory(:user)
    @reference_tree = Factory(:reference_tree)
    @dwc_object_id = 333
    @gnaclr_importer = Factory(:gnaclr_importer, :reference_tree => @reference_tree, :status => 'test', :message => 'test message')
    @logger = GnaclrImporterLogger.new
  end

  describe "#subscribe" do
    it "should create subscription" do
      @logger.subscribe(:dwc_object_id => @dwc_object_id, :reference_tree_id => @reference_tree.id)
      @logger.subscriptions[@dwc_object_id].should == @reference_tree.id
    end
  end

  describe "#unsubscribe" do
    it "should remove subscription" do
      @logger.subscribe(:dwc_object_id => @dwc_object_id, :reference_tree_id => @reference_tree.id)
      @logger.subscriptions[@dwc_object_id].should == @reference_tree.id
      @logger.unsubscribe(@dwc_object_id)
      @logger.subscriptions[@dwc_object_id].should be_nil
    end
  end

  describe "#info" do
    before(:each) do
      @logger.subscribe(:dwc_object_id => @dwc_object_id, :reference_tree_id => @reference_tree.id)
    end

    it 'should ignore logs that do not have pipe delimited object_id and message' do
      count = GnaclrImporterLog.count
      @logger.info('wrong kind of string')
      GnaclrImporterLog.count.should == count
    end

    it 'should take a pipe delimited string, split it on object_id and a message, and saves a row in a log table' do
      count = GnaclrImporterLog.count
      GnaclrImporter.find(@gnaclr_importer.id).message.should == 'test message'
      @logger.info("|#{@dwc_object_id}|my message|")
      GnaclrImporterLog.count.should == count + 1
      gil = GnaclrImporterLog.last
      gil.reference_tree.id.should == @reference_tree.id
      gil.message.should == 'my message'
      GnaclrImporter.find(@gnaclr_importer.id).message.should == 'my message'
    end

    it 'should ignore messages belogning to unsubscribed trees' do
      @logger.unsubscribe(@dwc_object_id)
      count = GnaclrImporterLog.count
      @logger.info("|#{@dwc_object_id}|my message|")
      GnaclrImporterLog.count.should == count
    end

    it 'should ignore logs with unknown dwc_object_ids' do
      count = GnaclrImporterLog.count
      @logger.info("|123|my message|")
      GnaclrImporterLog.count.should == count
    end

  end

end
