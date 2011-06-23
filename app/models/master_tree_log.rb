class MasterTreeLog < ActiveRecord::Base
  belongs_to :master_tree
  belongs_to :user
end