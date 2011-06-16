class CreateMergeResultPrimaries < ActiveRecord::Migration
  def self.up
    create_table :merge_result_primaries do |t|
      t.references :merge_event
      t.references :node
      t.text :path

      t.timestamps
    end
  end

  def self.down
    drop_table :merge_result_primaries
  end
end
