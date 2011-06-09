class CreateMergeTypes < ActiveRecord::Migration
  def self.up
    create_table :merge_types do |t|
      t.string :label
    end

    execute "load data infile '#{File.join(Rails.root, 'db', 'csv', 'merge_types.csv')}' into table merge_types character set utf8"  
  end

  def self.down
    drop_table :merge_types
  end
end
