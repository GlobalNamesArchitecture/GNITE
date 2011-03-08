class AddJsonMessageToActionCommand < ActiveRecord::Migration
  def self.up
    add_column :action_commands, :json_message, :string
  end

  def self.down
    remove_column :action_commands, :json_message
  end
end
