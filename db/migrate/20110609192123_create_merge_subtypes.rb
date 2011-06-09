class CreateMergeSubtypes < ActiveRecord::Migration
  def self.up
    create_table :merge_subtypes do |t|
      t.string :label
    end

    execute "load data infile '#{File.join(Rails.root, 'db', 'csv', 'merge_subtypes.csv')}' into table merge_subtypes character set utf8"  
  end

  def self.down
    drop_table :merge_subtypes
  end
end
