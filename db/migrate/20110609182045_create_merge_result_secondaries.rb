class CreateMergeResultSecondaries < ActiveRecord::Migration
  def self.up
    create_table :merge_result_secondaries do |t|
      t.references :merge_result_primary
      t.references :node
      t.references :merge_type
      t.references :merge_subtype
      t.text :path
      t.references :merge_decision

      t.timestamps
    end

    add_index :merge_result_secondaries, [:merge_type_id, :merge_subtype_id], name: :index_merge_results_secondaries_1
    add_index :merge_result_secondaries, :merge_decision_id, name: :index_merge_results_secondaries_2
  end

  def self.down
    drop_table :merge_result_secondaries
  end
end
