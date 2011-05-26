require 'spec_helper'

describe GnaclrImporter, 'create' do
  let(:reference_tree) { Factory(:reference_tree) }

  subject { GnaclrImporter.create(:reference_tree => reference_tree,
                               :url               => 'http://example.com') }
  it 'sets reference_tree' do
    subject.reference_tree.should == reference_tree
  end

  it 'sets the url' do
    subject.url.should == 'http://example.com'
  end
end

describe GnaclrImporter, 'import a tree for a valid dwc archive' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.create(:url => "file:///#{Rails.root.join('features', 'support', 'fixtures', 'cyphophthalmi.tar.gz')}", :reference_tree => reference_tree) }

  it "should import darwin core file into a reference tree" do
    subject.reference_tree.is_a?(ReferenceTree).should be_true
    subject.reference_tree.nodes.size.should == 1 #automatically created root node
    subject.import
    subject.reference_tree.nodes.size.should > 100
    require 'ruby-debug'; debugger
    puts ''
  end
end
