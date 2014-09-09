class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :name
      t.string :iso_639_1
      t.string :iso_639_2
      t.string :iso_639_3
      t.string :native
      t.timestamps
    end
    
    add_index :languages, :iso_639_1, uniq: true, name: :index_languages_on_iso_639_1

    execute "load data infile '#{File.join(Rails.root, 'db', 'csv', 'languages.csv')}' into table languages character set utf8"  
  end

  def self.down
    drop_table :languages
  end
end
