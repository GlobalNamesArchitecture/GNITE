class AddAncestryToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :ancestry, :string
    add_index :nodes, :ancestry
  end

  def self.down
    remove_index :nodes, :column => :ancestry
    remove_column :nodes, :ancestry
  end
end
