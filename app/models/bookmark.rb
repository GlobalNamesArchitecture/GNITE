class Bookmark < ActiveRecord::Base
  validates_uniqueness_of :node_id
  
  has_many :nodes
end