class CreateVernacularName < ActiveRecord::Migration
  def self.up
    create_table :vernacular_names do |t|
      t.references :node
      t.references :name
      t.timestamps
    end

    add_index :vernacular_names, [:node_id, :name_id], :unique => true
  end

  def self.down
    drop_table :vernacular_names
  end
end
