require 'spec_helper'

describe GnaclrImporter, 'new' do
  let(:reference_tree) { Factory(:reference_tree) }

  subject { GnaclrImporter.new(:reference_tree_id => reference_tree.id,
                               :url               => 'foo') }
  before do
    Delayed::Job.stubs(:enqueue)
  end

  it 'sets reference_tree_id' do
    subject.reference_tree_id.should be_a(Integer)
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

describe GnaclrImporter, 'store_tree for an invalid dwc archive' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.new(:url               => "file:///#{Rails.root.join('features', 'support', 'fixtures', 'cyphophthalmi.tar.gz')}",
                               :reference_tree_id => reference_tree.id) }

  before do
    Delayed::Job.stubs(:enqueue)
    core_mock = mock('dwc-core')
    subject.dwc.stubs(:core => core_mock)
    core_mock.stubs(:read => [[], ['some error']])
  end

  it 'calls dwc.core.read' do
    lambda { subject.store_tree }.should raise_error GnaclrImporter::InvalidDwcArchiveError
  end
end

describe GnaclrImporter, 'store_tree for a valid dwc archive' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.new(:url               => "file:///#{Rails.root.join('features', 'support', 'fixtures', 'cyphophthalmi.tar.gz')}",
                               :reference_tree_id => reference_tree.id) }
  let(:data) {
    [
      ["cyphophthalmi:tid:314", "http://cyphophthalmi.lifedesks.org/pages/314", "Cyphophthalmi incertae sedis", "/N", "family", nil],
      ["cyphophthalmi:tid:302", "http://cyphophthalmi.lifedesks.org/pages/302", "Opiliones", "/N", "order", nil],
      ["cyphophthalmi:tid:328", "http://cyphophthalmi.lifedesks.org/pages/328", "Dyspnoi", "cyphophthalmi:tid:302", nil, nil]
    ]
  }
  before do
    Delayed::Job.stubs(:enqueue)
    core_mock = mock('dwc-core')
    subject.dwc.stubs(:core => core_mock)
    core_mock.stubs(:read => [data, []])

    subject.stubs(:id_index        => 0,
                  :name_index      => 2,
                  :parent_id_index => 3)
    subject.store_tree
  end

  it 'creates node records' do
    first_node = Node.find_by_name!('Cyphophthalmi incertae sedis')
    first_node.parent.should be_nil
    second_node = Node.find_by_name!('Opiliones')
    second_node.parent.should be_nil
    third_node = Node.find_by_name!('Dyspnoi')
    third_node.parent.should == second_node
  end
end

describe GnaclrImporter, 'activate_tree' do
  let(:reference_tree) { Factory(:reference_tree, :state => 'importing') }
  subject { GnaclrImporter.new(:url               => "file:///#{Rails.root.join('features', 'support', 'fixtures', 'cyphophthalmi.tar.gz')}",
                               :reference_tree_id => reference_tree.id) }

  before do
    Delayed::Job.stubs(:enqueue)
    subject.activate_tree
  end

  it 'activates the reference tree' do
    reference_tree.reload.state.should == 'active'
  end
end

describe GnaclrImporter, 'perform' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.new(:url               => "",
                               :reference_tree_id => reference_tree.id) }

  before do
    Delayed::Job.stubs(:enqueue)
    subject.stubs(:fetch_tarball => nil,
                  :store_tree    => nil,
                  :read_tarball  => nil,
                  :activate_tree => nil)
  end

  it 'fetches, reads and stores the tree' do
    subject.perform
    subject.should have_received(:fetch_tarball)
    subject.should have_received(:read_tarball)
    subject.should have_received(:store_tree)
    subject.should have_received(:activate_tree)
  end
end
