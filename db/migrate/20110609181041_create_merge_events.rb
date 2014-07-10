class CreateMergeEvents < ActiveRecord::Migration
  def self.up
    create_table :merge_events do |t|
      t.references :master_tree
      t.references :primary_node, class: Node
      t.references :secondary_node, class: Node
      t.references :user
      t.string :memo
      t.string :status
      t.timestamps
    end

    add_index :merge_events, :master_tree_id, name: :index_merge_events_on_master_tree_id
  end

  def self.down
    drop_table :merge_events
  end
end
