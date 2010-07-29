class Tree < ActiveRecord::Base
  validates_presence_of :title
  belongs_to :user
  validates_presence_of :user_id
end
