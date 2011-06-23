class MasterTreeLogs < ActiveRecord::Migration
  def self.up
    create_table :master_tree_logs do |t|
      t.references :master_tree
      t.references :user
      t.text :message
      t.timestamps
    end
  end

  def self.down
    drop_table :master_tree_logs
  end
end
