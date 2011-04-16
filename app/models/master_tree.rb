class MasterTree < Tree
  has_one :deleted_tree
  has_many :master_tree_contributors
  has_many :reference_tree_collections
  has_many :reference_trees, :through => :reference_tree_collections
  has_many :users, :through => :master_tree_contributors

  attr_accessor :user

  after_create :create_deleted_tree, :create_contributor

  def create_darwin_core_archive
    dwca_file = File.join(::Rails.root.to_s, 'tmp', "#{uuid}.tar.gz")
    g = DarwinCore::Generator.new(dwca_file)
    records = Node.connection.select_rows("select nd.id, nd.parent_id, nd.local_id, names.name_string, nd.rank, nd.updated_at from nodes nd inner join names on names.id = nd.name_id where nd.tree_id = #{id}")
    records.unshift core_fields
    g.add_core(records, 'core.csv')
    g.add_meta_xml
    g.add_eml_xml(eml_xml)
    g.pack
    g.clean
    dwca_file
  end

  private
  def core_fields
    [ "http://rs.tdwg.org/dwc/terms/taxonID",
      "http://rs.tdwg.org/dwc/terms/parentNameUsageID",
      "http://rs.tdwg.org/dwc/terms/datasetID",
      "http://rs.tdwg.org/dwc/terms/scientificName",
      "http://rs.tdwg.org/dwc/terms/taxonRank",
      "http://purl.org/dc/terms/modified" ]
  end

  def eml_xml
    {
      :id => uuid,
      :title => title,
      :authors => get_authors,
      :abstract => abstract,
      :citation => citation,
      :pubDate => Time.now
    }
  end

  def get_authors
    self.users.map { |u| { :first_name => nil, :last_name => nil, :email => u.email } }
  end

  def create_contributor
    return unless self.user
    MasterTreeContributor.create!(:master_tree => self, :user => self.user)
    self.user = nil
  end

  def create_deleted_tree
    DeletedTree.create!(:master_tree => self, :title => "Deleted Names")
  end
  
end
