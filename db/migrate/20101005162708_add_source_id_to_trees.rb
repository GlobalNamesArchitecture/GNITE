class AddSourceIdToTrees < ActiveRecord::Migration
  def self.up
    add_column :trees, :source_id, :string
    add_index  :trees, :source_id
  end

  def self.down
    remove_index  :trees, :column => :source_id
    remove_column :trees, :source_id
  end
end
