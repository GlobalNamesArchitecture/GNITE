class AddProfileToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :given_name, :string, :limit => 128
    add_column :users, :surname, :string, :limit => 128
    add_column :users, :affiliation, :string
  end

  def self.down
    remove_column :users, :given_name
    remove_column :users, :surname
    remove_column :users, :affiliation
  end
end