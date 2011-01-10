class CreateDeletedTrees < ActiveRecord::Migration
  def self.up
    master_tree_ids_with_deleted_trees = DeletedTree.all.map {|dt| dt.master_tree.id}.uniq.join(",")
    MasterTree.where("id not in (#{master_tree_ids_with_deleted_trees})").each do |master_tree|
      DeletedTree.create!(:title => 'Deleted Names', :master_tree => master_tree, :user => master_tree.user)
    end
  end

  def self.down
    DeletedTree.all.each do |tree|
      tree.destroy_with_children
    end
  end
end
