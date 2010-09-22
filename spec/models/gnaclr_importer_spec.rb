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

  it 'sets normalized node data' do
    subject.darwin_core_data.should be_a(Hash)
  end
end

describe GnaclrImporter, 'store_tree for a valid dwc archive' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.new(:url               => "file:///#{Rails.root.join('features', 'support', 'fixtures', 'cyphophthalmi.tar.gz')}",
                               :reference_tree_id => reference_tree.id) }
  let(:data) do
    { "cyphophthalmi:tid:402" => @taxon1,
      "cyphophthalmi:tid:375" => @taxon2,
      "cyphophthalmi:tid:330" => @taxon3 }
  end

  before do
    @taxon1 = DarwinCore::TaxonNormalized.new
    @taxon1.current_name="Suzukielus sauteri"
    @taxon1.classification_path=["Opiliones", "Cyphophthalmi", "Sironidae", "Suzukielus", "Suzukielus sauteri"]
    @taxon1.id="cyphophthalmi:tid:402"
    @taxon1.rank="species"
    @taxon1.parent_id="cyphophthalmi:tid:375"
    @taxon1.current_name_canonical="Suzukielus sauteri"

    @taxon2 = DarwinCore::TaxonNormalized.new
    @taxon2.current_name="Suzukielus"
    @taxon2.classification_path=["Opiliones", "Cyphophthalmi", "Sironidae", "Suzukielus"]
    @taxon2.id="cyphophthalmi:tid:375"
    @taxon2.rank="genus"
    @taxon2.parent_id="cyphophthalmi:tid:330"
    @taxon2.current_name_canonical="Suzukielus"

    @taxon3 = DarwinCore::TaxonNormalized.new
    @taxon3.current_name="Sironidae"
    @taxon3.classification_path=["Opiliones", "Cyphophthalmi", "Sironidae"]
    @taxon3.id="cyphophthalmi:tid:330"
    @taxon3.rank="family"
    @taxon3.current_name_canonical="Sironidae"

    Delayed::Job.stubs(:enqueue)
    subject.stubs(:darwin_core_data => data,
                  :name_strings     => data.values.collect(&:current_name),
                  :tree             => { @taxon3.id => { @taxon2.id => { @taxon1.id => {} } } })
    subject.store_tree
  end

  it 'creates name records with associated nodes' do
    root_name = Name.find_by_name_string!("Sironidae")
    root_node = root_name.nodes.first
    root_node.parent.should be_nil

    branch_name = Name.find_by_name_string!("Suzukielus")
    branch_node = branch_name.nodes.first
    branch_node.parent.should == root_node

    leaf_name = Name.find_by_name_string!("Suzukielus sauteri")
    leaf_node = leaf_name.nodes.first
    leaf_node.parent.should == branch_node
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
