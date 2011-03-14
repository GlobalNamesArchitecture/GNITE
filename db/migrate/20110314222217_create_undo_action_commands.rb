class CreateUndoActionCommands < ActiveRecord::Migration
  def self.up
    create_table :undo_action_commands do |t|
      t.references :master_tree
      t.references :action_command
      t.timestamps
    end

    add_index :undo_action_commands, [:master_tree_id, :action_command_id], :name => "index_undo_action_commands_on_master_tree_and_action_command"
  end

  def self.down
    drop_table :undo_action_commands
  end
end
