class CreateMergeSubtypes < ActiveRecord::Migration
  def self.up
    create_table :merge_subtypes do |t|
      t.string :label
    end 
  end

  def self.down
    drop_table :merge_subtypes
  end
end
