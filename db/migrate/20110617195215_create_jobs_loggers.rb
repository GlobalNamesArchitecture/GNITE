class CreateJobsLoggers < ActiveRecord::Migration
  def self.up
    drop_table :gnaclr_importer_logs
    create_table :jobs_logs do |t|
      t.references :tree
      t.string :job_type
      t.string :message
      t.timestamps
    end

    add_index :jobs_logs, :tree_id, name: :index_jobs_logs_on_tree_id
  end

  def self.down
    drop_table :jobs_logs
    create_table :gnaclr_importer_logs do |t|
      t.references :reference_tree
      t.string :message
      t.timestamps
    end

    add_index :gnaclr_importer_logs, :reference_tree_id
    
  end
end
