class Tree < ActiveRecord::Base
  validates_presence_of :title
  belongs_to :user
  validates_presence_of :user_id
  has_many :nodes

  validates_inclusion_of :creative_commons, :in => Licenses::CC_LICENSES.map{|elt| elt.last }
  after_initialize :set_uuid

  def children_of(parent_id)
    if parent_id && Node.exists?(parent_id)
      nodes.find(parent_id).children
    else
      nodes.roots
    end
  end

  private

  def set_uuid
    self.uuid = UUID.new.generate unless self.uuid
  end
end
