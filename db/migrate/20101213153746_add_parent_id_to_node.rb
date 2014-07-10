class AddParentIdToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :parent_id, :integer
    remove_column :nodes, :ancestry
    add_index :nodes, :parent_id, name: 'index_nodes_on_parent_id'
  end

  def self.down
    add_column :nodes, :ancestry, :string
    remove_column :nodes, :parent_id
  end
end
