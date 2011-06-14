class ChangeActionCommands < ActiveRecord::Migration
  def self.up
    change_column :action_commands, :json_message, :text
  end

  def self.down
    change_column :action_commands, :json_message, :string
  end
end
