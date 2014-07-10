class AddStateToTree < ActiveRecord::Migration
  def self.up
    add_column :trees, :state, :string, default: 'active', null: false
  end

  def self.down
    remove_column :trees, :state
  end
end
