class DeletedTree < Tree
  belongs_to :master_tree
  before_create :set_title

  validates_presence_of :master_tree

  private

  def set_title
    self.title = "Deleted Names"
  end
end
