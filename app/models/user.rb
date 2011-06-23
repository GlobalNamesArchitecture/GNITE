class User < ActiveRecord::Base
  include Clearance::User
  has_many :action_commands
  has_many :master_tree_contributors
  has_many :master_trees, :through => :master_tree_contributors
  has_many :master_tree_logs
  has_many :merge_events
end
