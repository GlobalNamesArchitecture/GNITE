class CreateMergeTypes < ActiveRecord::Migration
  def self.up
    create_table :merge_types do |t|
      t.string :label
    end 
  end

  def self.down
    drop_table :merge_types
  end
end
