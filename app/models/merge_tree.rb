class MergeTree < Tree
  has_one :merge_event
  before_validation :set_title

  private

  def set_title
    self.title = "Merge Preview"
  end
end
