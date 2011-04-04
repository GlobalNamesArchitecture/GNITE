class MasterTreeContributor < ActiveRecord::Base
  belongs_to :master_tree
  belongs_to :user
  validates_presence_of :master_tree
  validates_presence_of :user
end
