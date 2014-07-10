class CreateReferenceTreeCollections < ActiveRecord::Migration
  def self.up
    create_table :reference_tree_collections do |t|
      t.references :reference_tree
      t.references :master_tree
      t.timestamps
    end

    add_index :reference_tree_collections, [:master_tree_id, :reference_tree_id], unique: true , name: 'index_rtc_on_master_tree_id_etc'
  end

  def self.down
    drop_table :reference_tree_collections
  end
end
