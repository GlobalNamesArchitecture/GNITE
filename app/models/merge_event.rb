class MergeEvent < ActiveRecord::Base
  belongs_to :master_tree
  belongs_to :user
  belongs_to :primary_node, :class => Node
  belongs_to :secondary_node, :class => Node

  has_many :merge_result_primaries
end
