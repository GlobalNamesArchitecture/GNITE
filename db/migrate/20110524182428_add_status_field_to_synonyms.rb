class AddStatusFieldToSynonyms < ActiveRecord::Migration
  def self.up
    add_column :synonyms, :status, :string
  end

  def self.down
    remove_column :synonyms, :status
  end
end
