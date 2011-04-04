class CreateMasterTreeContributors < ActiveRecord::Migration
  def self.up
    create_table :master_tree_contributors do |t|
      t.references :master_tree
      t.references :user
      t.timestamps
    end

    add_index :master_tree_contributors, [:user_id, :master_tree_id], :unique => true, :name => 'index_master_tree_contributors_on_user_id_and_master_tree_id'
  end

  def self.down
    drop_table :master_tree_contributors
  end
end
