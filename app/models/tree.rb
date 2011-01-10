class Tree < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :user_id
  belongs_to :user
  has_many :nodes

  validates_inclusion_of :creative_commons, :in => Licenses::CC_LICENSES.map{|elt| elt.last }
  after_initialize :set_defaults

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
  def destroy_with_children
    destroy
  end

  private

  def set_defaults
    self.uuid = UUID.new.generate unless self.uuid
    self.creative_commons = "cc0"
  end
end
