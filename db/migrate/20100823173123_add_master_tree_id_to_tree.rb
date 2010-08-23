class AddMasterTreeIdToTree < ActiveRecord::Migration
  def self.up
    add_column :trees, :master_tree_id, :integer
  end

  def self.down
    remove_column :trees, :master_tree_id
  end
end
