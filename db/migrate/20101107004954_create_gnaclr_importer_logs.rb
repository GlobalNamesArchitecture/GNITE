class CreateGnaclrImporterLogs < ActiveRecord::Migration
  def self.up
    create_table :gnaclr_importer_logs do |t|
      t.references :reference_tree
      t.string :message
      t.timestamps
    end

    add_index :gnaclr_importer_logs, :reference_tree_id
  end

  def self.down
    drop_table :gnaclr_importer_logs
  end
end
