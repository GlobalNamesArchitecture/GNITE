class RemoveSourceIdTree < ActiveRecord::Migration
  def self.up
    remove_column :trees, :source_id
  end

  def self.down
    add_column :trees, :source_id, :string
    add_index :trees, :source_id, :name => :index_trees_on_source_id
  end
end
