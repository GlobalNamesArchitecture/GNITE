class Lexicalable < ActiveRecord::Migration
  def self.up
    create_table :lexical_variants do |t|
      t.references :name, :null => false
      t.references :lexicalable, :polymorphic => true
      t.timestamps
    end
    
    add_index :lexical_variants, [:lexicalable_id, :lexicalable_type]
  end

  def self.down
    drop_table :lexical_variants
  end
end
