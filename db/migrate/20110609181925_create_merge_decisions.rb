class CreateMergeDecisions < ActiveRecord::Migration
  def self.up
    create_table :merge_decisions do |t|
      t.string :label
    end

    execute "load data infile '#{File.join(Rails.root, 'db', 'csv', 'merge_decisions.csv')}' into table merge_decisions character set utf8"  
  end

  def self.down
    drop_table :merge_decisions
  end
end
