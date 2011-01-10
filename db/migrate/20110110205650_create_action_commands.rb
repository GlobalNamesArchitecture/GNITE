class CreateActionCommands < ActiveRecord::Migration
  def self.up
    create_table :action_commands do |t|
      t.string :type
      t.references :user
      t.boolean :undo
      t.integer :node_id
      t.integer :parent_id
      t.integer :destination_node_id
      t.integer :destination_parent_id
      t.string  :old_name
      t.string  :new_name
      t.timestamps
    end
  end

  def self.down
    drop_table :action_commands
  end
end
