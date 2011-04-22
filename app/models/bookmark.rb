class Bookmark < ActiveRecord::Base
  validates_presence_of :node_id, :bookmark_title
  
  belongs_to :node
end