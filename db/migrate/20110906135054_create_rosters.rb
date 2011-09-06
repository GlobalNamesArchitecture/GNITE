class CreateRosters < ActiveRecord::Migration
  def self.up
    create_table :rosters do |t|
      t.references :master_tree
      t.timestamps
    end
  end

  def self.down
    drop_table :rosters
  end
end
