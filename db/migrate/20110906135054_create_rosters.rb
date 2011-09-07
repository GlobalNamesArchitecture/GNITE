class CreateRosters < ActiveRecord::Migration
  def self.up
    create_table :rosters do |t|
      t.references :master_tree
      t.references :user
      t.timestamps
    end
    
    add_index :rosters, [:master_tree_id, :user_id]
  end

  def self.down
    drop_table :rosters
  end
end
