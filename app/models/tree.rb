class Tree < ActiveRecord::Base
  validates_presence_of :title
  belongs_to :user
  validates_presence_of :user_id
  has_many :nodes
end
