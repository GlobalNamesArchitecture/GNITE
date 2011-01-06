class CreateGnaclrPublisher < ActiveRecord::Migration
  def self.up
    create_table(:gnaclr_publishers) do |t|
      t.references :master_tree
      t.string :status
      t.timestamps
    end

    add_index :gnaclr_publishers, :master_tree_id
  end

  def self.down
    drop_table :gnaclr_publishers
  end
end
