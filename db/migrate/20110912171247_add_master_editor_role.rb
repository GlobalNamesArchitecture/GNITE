class AddMasterEditorRole < ActiveRecord::Migration
  def self.up
    execute "INSERT INTO roles (name, created_at, updated_at) VALUES ('master_editor', NOW(), NOW())"
  end

  def self.down
    execute "DELETE FROM roles WHERE name = 'master_editor'"
  end
end
