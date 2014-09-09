class AddNodeIdIndexToBookmarks < ActiveRecord::Migration
  def self.up
    add_index :bookmarks, :node_id, name: 'index_bookmarks_on_node_id'
  end

  def self.down
    remove_index :bookmarks, :node_id
  end
end
