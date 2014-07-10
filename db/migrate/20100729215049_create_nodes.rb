class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.integer :tree_id
      t.string :name

      t.timestamps
    end

    add_index :nodes, :tree_id
  end

  def self.down
    remove_index :nodes, column: :tree_id

    drop_table :nodes
  end
end
