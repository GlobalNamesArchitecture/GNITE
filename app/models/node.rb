class Node < ActiveRecord::Base
  validates_presence_of :name, :tree_id
  belongs_to :tree
  has_ancestry

  def deep_copy
    copy = self.clone
    copy.save

    children.each do |child|
      child_copy = child.deep_copy
      child_copy.parent = copy
      child_copy.save
    end

    copy.reload
  end
end
