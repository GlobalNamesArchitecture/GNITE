class CreateVocabularies < ActiveRecord::Migration
  def self.up
    create_table :vocabularies do |t|
      t.string :name
      t.string :identifier
      t.string :uri
      t.text :description
      t.timestamps
    end
    
    add_index :vocabularies, :identifier, :unique => true

    execute "load data infile '#{File.join(Rails.root, 'db', 'csv', 'vocabularies.csv')}' into table vocabularies character set utf8"
    
    create_table :terms do |t|
      t.references :vocabulary
      t.string :name
      t.string :identifier
      t.string :uri
      t.text :description
      t.timestamps
    end
    
    add_index :terms, :vocabulary_id, :name => 'index_terms_on_vocabulary_id'

    execute "load data infile '#{File.join(Rails.root, 'db', 'csv', 'terms.csv')}' into table terms character set utf8"
    
  end

  def self.down
    drop_table :vocabularies
    drop_table :terms
  end
end
