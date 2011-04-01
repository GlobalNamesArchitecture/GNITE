class Bookmark < ActiveRecord::Base
  validates_presence_of :node_id
  
  belongs_to :node
end