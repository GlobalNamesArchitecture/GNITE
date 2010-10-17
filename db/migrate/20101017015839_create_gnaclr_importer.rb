class CreateGnaclrImporter < ActiveRecord::Migration
  def self.up
    create_table(:gnaclr_importers) do |t|
      t.references :reference_tree
      t.string     :url
      t.integer    :status
      t.string     :message
      t.timestamps
    end
  end

  def self.down
    drop_table :gnaclr_importers
  end
end
