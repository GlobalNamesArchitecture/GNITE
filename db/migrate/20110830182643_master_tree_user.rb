class MasterTreeUser < ActiveRecord::Migration
  def self.up
    change_table :trees do |t|
      t.references :user
    end
    
    #delete master_trees_contributors - how?
    #update trees to have a user_id for the owner - how?
    execute "TRUNCATE TABLE master_tree_contributors"
  end

  def self.down
    remove_column :trees, :user_id
  end
end
