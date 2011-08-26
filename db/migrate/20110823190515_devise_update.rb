class DeviseUpdate < ActiveRecord::Migration
  def self.up
    
    #remove most columns created by devise
    remove_column :users, :salt
    remove_column :users, :confirmation_token
    remove_column :users, :remember_token
    
    #add columns for devise
    change_table(:users) do |t|
      t.recoverable
      t.rememberable
      t.trackable
      t.confirmable
      t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
    end
    
    change_column :users, :encrypted_password, :string, :limit => 255
    
    #if email_confirmed, update the confirmed_at column
    execute "UPDATE users SET confirmed_at = NOW() WHERE email_confirmed = 1"
    
    #remove remaining column created with clearance
    remove_column :users, :email_confirmed
    
    # add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true

  end

  def self.down
    remove_column :users, :confirmation_token
    
    add_column :users, :salt, :string, :limit => 128
    add_column :users, :remember_token, :string, :limit => 128
    add_column :users, :confirmation_token, :string, :limit => 128
    add_column :users, :email_confirmed, :boolean, :default => false, :null => false
    
    execute "UPDATE users SET email_confirmed = 1 WHERE confirmed_at <> ''"
    
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :failed_attempts
    remove_column :users, :unlock_token
    remove_column :users, :locked_at
    
    add_index :users, :remember_token
  end
end
