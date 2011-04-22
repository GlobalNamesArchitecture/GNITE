class AddBookmarkTitle < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :bookmark_title, :string, :null => false, :default => '', :limit => 128
  end

  def self.down
    remove_column :bookmarks, :bookmark_title
  end
end