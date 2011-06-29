class UpdateMergeEvents < ActiveRecord::Migration
  def self.up
    add_column :merge_events, :merge_tree_id, :integer
  end

  def self.down
    remove_column :merge_events, :merge_tree_id
  end
end
