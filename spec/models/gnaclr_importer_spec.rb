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

describe GnaclrImporter, 'store_tree for a valid dwc archive' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.create(:url            => "file:///#{Rails.root.join('features', 'support', 'fixtures', 'cyphophthalmi.tar.gz')}",
                               :reference_tree => reference_tree) }
  let(:data) do
    { "cyphophthalmi:tid:402" => @taxon1,
      "cyphophthalmi:tid:375" => @taxon2,
      "cyphophthalmi:tid:330" => @taxon3,
      "cyphophthalmi:tid:378" => @taxon4 }
  end

  before do
    @taxon1                        = DarwinCore::TaxonNormalized.new
    @taxon1.current_name           = "Suzukielus sauteri"
    @taxon1.classification_path    = ["Opiliones", "Cyphophthalmi", "Sironidae", "Suzukielus", "Suzukielus sauteri"]
    @taxon1.id                     = "cyphophthalmi:tid:402"
    @taxon1.rank                   = "species"
    @taxon1.parent_id              = "cyphophthalmi:tid:375"
    @taxon1.current_name_canonical = "Suzukielus sauteri"

    @taxon2                        = DarwinCore::TaxonNormalized.new
    @taxon2.current_name           = "Suzukielus"
    @taxon2.classification_path    = ["Opiliones", "Cyphophthalmi", "Sironidae", "Suzukielus"]
    @taxon2.id                     = "cyphophthalmi:tid:375"
    @taxon2.rank                   = "genus"
    @taxon2.parent_id              = "cyphophthalmi:tid:330"
    @taxon2.current_name_canonical = "Suzukielus"

    @taxon3                        = DarwinCore::TaxonNormalized.new
    @taxon3.current_name           = "Sironidae"
    @taxon3.classification_path    = ["Opiliones", "Cyphophthalmi", "Sironidae"]
    @taxon3.id                     = "cyphophthalmi:tid:330"
    @taxon3.rank                   = "family"
    @taxon3.current_name_canonical = "Sironidae"

    @taxon4                        = DarwinCore::TaxonNormalized.new
    @taxon4.current_name           = "Opiliones"
    @taxon4.classification_path    = ["Opiliones", "Sironidae"]
    @taxon4.id                     = "cyphophthalmi:tid:378"
    @taxon2.parent_id              = "cyphophthalmi:tid:330"
    @taxon4.current_name_canonical = "Opiliones"

    subject.stubs(:darwin_core_data => data,
                  :name_strings     => data.values.collect(&:current_name),
                  :tree             => { @taxon3.id => { @taxon2.id => { @taxon1.id => {} }, @taxon4.id => {} } })
    subject.store_tree
  end

  it 'creates name records with associated nodes with rank' do
    root_name = Name.find_by_name_string!("Sironidae")
    root_node = root_name.nodes.first
    root_node.parent.should == root_node.tree.root
    root_node.rank.should == 'family'

    branch_name = Name.find_by_name_string!("Suzukielus")
    branch_node = branch_name.nodes.first
    branch_node.parent.should == root_node
    branch_node.rank.should == 'genus'

    leaf_name = Name.find_by_name_string!("Suzukielus sauteri")
    leaf_node = leaf_name.nodes.first
    leaf_node.parent.should == branch_node
    leaf_node.rank.should == 'species'

    root_name_2 = Name.find_by_name_string!("Opiliones")
    root_node_2 = root_name_2.nodes.first
    root_node_2.parent.should == root_node
    root_node_2.rank.should be_nil
  end
end

describe GnaclrImporter, 'store tree with nodes that have synonyms and vernacular names' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.create(:url            => "file:///#{Rails.root.join('features', 'support', 'fixtures', 'cyphophthalmi.tar.gz')}",
                               :reference_tree => reference_tree) }
  let(:data) { { 'cyphophthalmi:tid:402' => @taxon } }
  let(:synonyms) { %w(one two three) }
  let(:vernacular_names) { %w(four five six seven) }

  before do
    name_struct = Struct.new(:name)
    @taxon                        = DarwinCore::TaxonNormalized.new
    @taxon.current_name           = "Suzukielus sauteri"
    @taxon.classification_path    = ["Opiliones", "Cyphophthalmi", "Sironidae", "Suzukielus", "Suzukielus sauteri"]
    @taxon.id                     = "cyphophthalmi:tid:402"
    @taxon.rank                   = "species"
    @taxon.current_name_canonical = "Suzukielus sauteri"
    @taxon.synonyms               = synonyms.map { |name| name_struct.new(name) }
    @taxon.vernacular_names       = vernacular_names.map { |name| name_struct.new(name) }
    #name_strings contain all name_strings processed during import
    name_strings = ([@taxon.current_name, @taxon.current_name_canonical] + @taxon.classification_path + synonyms + vernacular_names).flatten

    subject.stubs(:darwin_core_data => data,
                  :name_strings     => name_strings,
                  :tree             =>  { @taxon.id => {} } )
    subject.store_tree
  end

  it 'stores synonyms' do
    reference_tree.nodes.second.synonyms.map(&:name).map(&:name_string).should include(*synonyms)
    reference_tree.nodes.second.synonyms.count.should == 3
  end

  it 'stores vernacular names' do
    reference_tree.nodes.second.vernacular_names.map(&:name).map(&:name_string).should include(*vernacular_names)
    reference_tree.nodes.second.vernacular_names.count.should == 4
  end

end

describe GnaclrImporter, 'activate_tree' do
  let(:reference_tree) { Factory(:reference_tree, :state => 'importing') }
  subject { GnaclrImporter.create(:url            => "file:///#{Rails.root.join('features', 'support', 'fixtures', 'cyphophthalmi.tar.gz')}",
                               :reference_tree => reference_tree) }

  before do
    subject.activate_tree
  end

  it 'activates the reference tree' do
    reference_tree.reload.state.should == 'active'
  end
end

describe GnaclrImporter, 'import when the classification has not been imported' do
  let(:reference_tree) { Factory(:reference_tree) }
  subject { GnaclrImporter.create(:url               => "",
                               :reference_tree    => reference_tree) }

  before do
    subject.stubs(:fetch_tarball => nil,
                  :store_tree    => nil,
                  :read_tarball  => nil,
                  :activate_tree => nil)
    subject.import
  end

  it 'fetches, reads and stores the tree' do
    subject.should have_received(:fetch_tarball)
    subject.should have_received(:read_tarball)
    subject.should have_received(:store_tree)
    subject.should have_received(:activate_tree)
  end
end

