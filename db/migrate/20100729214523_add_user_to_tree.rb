class AddUserToTree < ActiveRecord::Migration
  def self.up
    add_column :trees, :user_id, :integer
  end

  def self.down
    remove_column :trees, :user_id
  end
end
