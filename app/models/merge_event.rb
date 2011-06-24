class MergeEvent < ActiveRecord::Base
  belongs_to :master_tree
  belongs_to :user
  belongs_to :node, :foreign_key => :primary_node_id
  belongs_to :node, :foreign_key => :secondary_node_id

  has_many :merge_result_primaries
  @queue = :merge_event
  
  def self.perform(merge_event_id)
    me = MergeEvent.find(merge_event_id)
    me.merge
    MergeResultPrimary.import_merge(me)
    me.status = "in review"
    me.save!
  end

  def merge
    unless @merge_data
      primary_data = Node.find(primary_node_id).merge_data
      secondary_data = Node.find(secondary_node_id).merge_data
      fr = FamilyReunion.new(primary_data, secondary_data)
      FamilyReunion.logger.subscribe(:an_object_id => fr.object_id, :tree_id => self.master_tree_id, :job_type => 'MergeEvent')
      @merge_data = fr.merge
    end
    @merge_data
  end

end
