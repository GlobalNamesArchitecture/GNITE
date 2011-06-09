class MergeResultPrimary < ActiveRecord::Base
  belongs_to :merge_event
  belongs_to :node
  has_many :merge_result_secondaries
end
