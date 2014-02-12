class CreateVocabularies < ActiveRecord::Migration
  def self.up
    create_table :controlled_vocabularies do |t|
      t.string :name
      t.string :identifier
      t.string :uri
      t.text :description
    end
    
    add_index :controlled_vocabularies, :identifier, :unique => true

    execute "load data infile '#{File.join(Rails.root, 'db', 'csv', 'controlled_vocabularies.csv')}' into table controlled_vocabularies character set utf8"
    
    create_table :controlled_terms do |t|
      t.references :controlled_vocabulary
      t.string :name
      t.string :identifier
      t.string :uri
      t.text :description
    end
    
    add_index :controlled_terms, :controlled_vocabulary_id

    execute "load data infile '#{File.join(Rails.root, 'db', 'csv', 'controlled_terms.csv')}' into table controlled_terms character set utf8"
    
  end

  def self.down
    drop_table :controlled_vocabularies
    drop_table :controlled_terms
  end
end
