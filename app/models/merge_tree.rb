class MergeTree < Tree
  has_one :merge_event
  before_validation :set_title

  def populate
    me = self.merge_event
    unless me.merge_result_primaries.limit(1).empty?
      root_node = me.primary_node.deep_merge(me)
      root_node.parent = me.merge_tree.root
      root_node.save!
      root_node.reload
    end
  end

  private

  def set_title
    self.title = "Merge Preview"
  end
end
