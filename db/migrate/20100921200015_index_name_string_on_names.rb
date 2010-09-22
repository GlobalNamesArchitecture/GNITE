class IndexNameStringOnNames < ActiveRecord::Migration
  def self.up
    add_index :names, :name_string
  end

  def self.down
    remove_index :names, :column => :name_string
  end
end
