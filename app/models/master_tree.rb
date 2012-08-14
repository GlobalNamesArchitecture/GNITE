class MasterTree < Tree
  belongs_to :user
  has_one :deleted_tree
  has_many :master_tree_contributors
  has_many :users, :through => :master_tree_contributors
  has_many :master_tree_logs
  has_many :reference_tree_collections
  has_many :reference_trees, :through => :reference_tree_collections
  has_many :merge_events
  has_many :rosters
  
  attr_accessor :user, :master_tree_contributor_ids

  after_create :create_deleted_tree, :create_contributor
  after_save :update_master_tree_contributors

  def create_darwin_core_archive
    dwca_file = File.join(::Rails.root.to_s, 'tmp', "#{uuid}.tar.gz")
    g = DarwinCore::Generator.new(dwca_file)
    records = Node.connection.select_rows("select nd.id, null, nd.local_id, names.name_string, nd.rank, nd.updated_at from nodes nd inner join names on names.id = nd.name_id where nd.tree_id = #{id} and nd.parent_id = #{self.root.id}")
    records += Node.connection.select_rows("select nd.id, nd.parent_id, nd.local_id, names.name_string, nd.rank, nd.updated_at from nodes nd inner join names on names.id = nd.name_id where nd.tree_id = #{id} and nd.id != #{self.root.id} and nd.parent_id != #{self.root.id}")
    records.unshift core_fields
    force_encode(records)
    g.add_core(records, 'core.csv')
    build_extension(g, VernacularName)
    build_extension(g, Synonym)
    g.add_meta_xml
    g.add_eml_xml(eml_xml)
    g.pack
    g.clean
    dwca_file
  end

  def nuke
    Tree.connection.execute("DELETE FROM master_tree_contributors WHERE master_tree_id = #{id}")
    Tree.find(self.deleted_tree.id).nuke
    super
  end
  
  def creator
    User.find(self.user_id) rescue nil
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
    self.users.map { |u| { :first_name => u.given_name, :last_name => u.surname, :email => u.email } }
  end
  
  def create_contributor
    return unless self.user
    MasterTreeContributor.create!(:master_tree => self, :user => self.user)
    self.user = nil
  end

  def create_deleted_tree
    DeletedTree.create!(:master_tree => self, :title => "Deleted Names")
  end

  def build_extension(dwca, klass)
    table_name = klass.table_name
    fields = klass.column_names
    #TODO HACK!!! Refactor at the earliest convenience!
    mapping = {
      "node_id" => "http://rs.tdwg.org/dwc/terms/taxonID",
      "name_id" => {"vernacular_names" => "http://rs.tdwg.org/dwc/terms/vernacularName", "synonyms" => "http://rs.tdwg.org/dwc/terms/scientificName"},
      "taxonomic_status" => "http://rs.tdwg.org/dwc/terms/taxonomicStatus",
      }
    query_fields = []
    header = []
    fields.each do |field|
      if mapping.key?(field)
        header << (mapping[field].is_a?(Hash) ? mapping[field][table_name] : mapping[field])
        query_fields << (field == 'name_id' ? "names.name_string" : "ext.#{field}")
      end
    end
    q = "select #{query_fields.join(", ")} FROM nodes n JOIN #{table_name} ext ON ext.node_id = n.id JOIN names ON names.id = ext.name_id WHERE n.tree_id = #{self.id}"
    res = Tree.connection.select_rows(q)
    res.unshift(header)
    force_encode(res, 'extension')
    dwca.add_extension(res, table_name + ".csv")
  end
  
  def update_master_tree_contributors
    unless master_tree_contributor_ids.nil?
      self.master_tree_contributors.each do |m|
        m.destroy unless master_tree_contributor_ids.include?(m.user_id.to_s)
        master_tree_contributor_ids.delete(m.user_id.to_s)
      end 
      master_tree_contributor_ids.each do |m|
        self.master_tree_contributors.create(:user_id => m) unless m.blank?
      end
      reload
      self.master_tree_contributor_ids = nil
    end
  end
  
  def force_encode(records, type = 'core')
    index = (type == 'core') ? 3 : 1
    records.each do |record|
      record[index].force_encoding("UTF-8") if record[index].is_a? String
    end
    records
  end

end
