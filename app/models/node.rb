class Node < ActiveRecord::Base
  validates_presence_of :name, :tree_id
  belongs_to :tree
  belongs_to :name

  has_many :synonyms
  has_many :vernacular_names

  has_ancestry

  delegate :name_string, :to => :name

  def self.find_by_id_for_user(id_to_find, user)
    # If we just called user.master_tree_ids here,
    # AR wouldn't load all the tree columns, causing Tree#after_initialize to fail when trying to read self.uuid
    tree_ids = user.master_trees.map(&:id) | user.reference_trees.map(&:id)
    find(:first, :conditions => ["id = ? and tree_id in (?)", id_to_find, tree_ids])
  end

  def deep_copy_to(tree)
    copy = self.clone
    copy.tree = tree
    copy.save

    children.each do |child|
      child_copy = child.deep_copy_to(tree)
      child_copy.parent = copy
      child_copy.save
    end

    copy.reload
  end
end
