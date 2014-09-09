class CreateRedoActionCommands < ActiveRecord::Migration
  def self.up
    create_table :redo_action_commands do |t|
      t.references :master_tree
      t.references :action_command
      t.timestamps
    end

    add_index :redo_action_commands, [:master_tree_id, :action_command_id], name: "index_redo_action_commands_on_master_tree_and_action_command"
  end

  def self.down
    drop_table :redo_action_commands
  end
end
