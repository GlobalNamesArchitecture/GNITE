class MergeEvent < ActiveRecord::Base
  belongs_to :master_tree
  belongs_to :user
  belongs_to :node, :foreign_key => :primary_node
  belongs_to :node, :foreign_key => :secondary_node

  has_many :merge_result_primaries

  def merge
    primary_data = Node.find(primary_node_id).merge_data
    secondary_data = Node.find(secondary_node_id).merge_data
    fr = FamilyReunion.new(primary_data, secondary_data)
    @merge_data = fr.merge
  end

end
