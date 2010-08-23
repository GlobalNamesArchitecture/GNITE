class User < ActiveRecord::Base
  include Clearance::User

  has_many :master_trees
  has_many :reference_trees
end
