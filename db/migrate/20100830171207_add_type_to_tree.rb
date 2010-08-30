class AddTypeToTree < ActiveRecord::Migration
  def self.up
    add_column :trees, :type, :string
  end

  def self.down
    remove_column :trees, :type
  end
end
