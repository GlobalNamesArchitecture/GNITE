class MergeResultSecondary < ActiveRecord::Base
  belongs_to :merge_result_primary
  belongs_to :node
  belongs_to :merge_type
  belongs_to :merge_subtype
  belongs_to :merge_decision
end
