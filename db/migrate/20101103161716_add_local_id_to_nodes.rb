class AddLocalIdToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :local_id, :string
    add_index :nodes, [:local_id, :tree_id], unique: true
  end

  def self.down
    remove_index :nodes, column: [:local_id, :tree_id]
    remove_column :nodes, :local_id
  end
end
