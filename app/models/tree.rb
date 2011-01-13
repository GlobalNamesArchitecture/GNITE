class Tree < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :user_id
  belongs_to :user
  has_many :nodes

  validates_inclusion_of :creative_commons, :in => Licenses::CC_LICENSES.map{|elt| elt.last }
  after_initialize :set_defaults
  after_create :create_root_node

  def children_of(parent_id)
    if parent_id && Node.exists?(parent_id)
      nodes.find(parent_id).children
    else
      Node.roots(id)
    end
  end

  def importing?
    state == 'importing'
  end

  def active?
    state == 'active'
  end

  def self.by_title
    self.order('title asc')
  end
  
  #TODO this is a placeholder! it needs to be done correctly
  def nuke
    Tree.connection.execute("delete n, s, v from nodes n left join synonyms s on s.node_id = n.id left join vernacular_names v on v.node_id = n.id where tree_id = #{id}")
    Tree.connection.execute("delete from nodes where tree_id = #{id}")
    destroy
  end

  def root
    @root ||= Node.where(:tree_id => self.id).where(:parent_id => nil).limit(1)[0]
  end
  
  private

  def set_defaults
    self.uuid = UUID.new.generate unless self.uuid
    self.creative_commons = "cc0"
  end

  def create_root_node
    name = Name.find_or_create_by_name_string(Gnite::Config.root_node_name_string)
    @root = Node.create!(:parent_id => nil, :tree => self, :name => name)
  end
  
end
