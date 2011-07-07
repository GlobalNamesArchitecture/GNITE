class RemoveIndexOnLocalId < ActiveRecord::Migration
  def self.up
    remove_index :nodes, :column => [:local_id, :tree_id]
    add_index :nodes, [:local_id, :tree_id], :unique => false
  end

  def self.down
    remove_index :nodes, :column => [:local_id, :tree_id]
    add_index :nodes, [:local_id, :tree_id], :unique => true
  end
end
