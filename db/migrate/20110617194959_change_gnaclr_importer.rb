class ChangeGnaclrImporter < ActiveRecord::Migration
  def self.up
    remove_column :gnaclr_importers, :message
  end

  def self.down
    add_column :gnaclr_importers, :message, :string
  end
end
