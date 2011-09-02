class MasterTreeUser < ActiveRecord::Migration
  def self.up
    change_table :trees do |t|
      t.references :user
    end
    
    #update trees to have a user_id for the owner - how?
    execute "UPDATE trees AS t INNER JOIN (SELECT * FROM master_tree_contributors mtc2 GROUP BY mtc2.master_tree_id) AS mtc ON t.id = mtc.master_tree_id SET t.user_id = mtc.user_id WHERE t.type = 'MasterTree'"
  end

  def self.down
    remove_column :trees, :user_id
  end
end
