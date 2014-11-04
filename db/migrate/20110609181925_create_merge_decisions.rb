class CreateMergeDecisions < ActiveRecord::Migration
  def self.up
    create_table :merge_decisions do |t|
      t.string :label
    end  
  end

  def self.down
    drop_table :merge_decisions
  end
end
