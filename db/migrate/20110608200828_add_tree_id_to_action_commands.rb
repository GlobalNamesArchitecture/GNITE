class AddTreeIdToActionCommands < ActiveRecord::Migration
  def self.up
    add_column :action_commands, :tree_id, :integer
    add_index :action_commands, :tree_id, name: :index_action_commands_on_tree_id
  end

  def self.down
    remove_column :action_commands, :tree_id
  end
end
