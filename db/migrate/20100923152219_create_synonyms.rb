class CreateSynonyms < ActiveRecord::Migration
  def self.up
    create_table :synonyms do |t|
      t.references :node
      t.references :name
      t.timestamps
    end

    add_index :synonyms, [:node_id, :name_id], :unique => true
  end

  def self.down
    drop_table :synonyms
  end
end
