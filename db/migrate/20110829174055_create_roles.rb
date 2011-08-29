class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.timestamps
    end
    
    execute "INSERT INTO roles (name, created_at, updated_at) VALUES ('admin', NOW(), NOW())"
  end

  def self.down
    drop_table :roles
  end
end
