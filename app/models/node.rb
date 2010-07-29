class Node < ActiveRecord::Base
  validates_presence_of :name, :tree_id
  belongs_to :tree
end
