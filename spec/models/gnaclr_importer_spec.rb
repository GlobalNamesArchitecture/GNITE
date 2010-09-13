require 'spec_helper'

describe GnaclrImporter, 'new' do
  let(:reference_tree) { Factory(:reference_tree) }

  subject { GnaclrImporter.new(:reference_tree_id => reference_tree.id,
                               :url               => 'foo') }

  before do
    Delayed::Job.stubs(:enqueue)
  end

  it 'sets reference_tree_id' do
    subject.reference_tree_id.should == reference_tree.id
  end

  it 'sets the url' do
    subject.url.should == 'foo'
  end

  it 'queues itself in delayed job' do
    Delayed::Job.should have_received(:enqueue).with(subject)
  end
end

describe GnaclrImporter, 'fetch_tarball with a successful download' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.new(:reference_tree_id => reference_tree.id) }

  before do
    Kernel.stubs(:system => 0)
    Delayed::Job.stubs(:enqueue)
    subject.fetch_tarball
  end

  it 'curls the provided url' do
    Kernel.should have_received(:system).
      with("curl -s #{subject.url} > #{Rails.root.join('tmp', reference_tree.id.to_s)}")
  end

end

describe GnaclrImporter, 'read_tarball' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.new(:url               => "file:///#{Rails.root.join('features', 'support', 'fixtures', 'cyphophthalmi.tar.gz')}",
                               :reference_tree_id => reference_tree.id) }

  before do
    Delayed::Job.stubs(:enqueue)
    subject.fetch_tarball
    subject.read_tarball
  end

  it 'sets dwc archive' do
    subject.dwc.should be_a(DarwinCore)
  end

  it 'extracts ID index' do
    subject.id_index.should == 0
  end

  it 'extracts name index' do
    subject.name_index.should == 2
  end

  it 'extracts parent ID index' do
    subject.parent_id_index.should == 3
  end
end
