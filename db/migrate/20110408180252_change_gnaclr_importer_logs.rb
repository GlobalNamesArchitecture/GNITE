class ChangeGnaclrImporterLogs < ActiveRecord::Migration
  def self.up
    remove_column :gnaclr_importer_logs, :reference_tree_id
    add_column :gnaclr_importer_logs, :gnaclr_importer_id, :integer
    add_index :gnaclr_importer_logs, :gnaclr_importer_id, :name => :index_gnaclr_importer_logs_on_gnaclr_importer_id
  end

  def self.down
    remove_column :gnaclr_importer_logs, :gnaclr_importer_id
    add_column :gnaclr_importer_logs, :reference_tree_id, :integer
    add_index :gnaclr_importer_logs, :reference_tree_id, :name => :index_gnaclr_importer_logs_on_reference_tree_id
  end
end
