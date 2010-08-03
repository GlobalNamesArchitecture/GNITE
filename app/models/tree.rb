class Tree < ActiveRecord::Base
  validates_presence_of :title
  belongs_to :user
  validates_presence_of :user_id
  has_many :nodes

  def children_of(parent_id)
    if parent_id && Node.exists?(parent_id)
      nodes.find(parent_id).children
    else
      nodes.roots
    end
  end
end
