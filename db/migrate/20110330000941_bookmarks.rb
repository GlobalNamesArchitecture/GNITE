class Bookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.references :node, null: false, unique: true
      t.timestamps
    end
  end

  def self.down
    drop_table :bookmarks
  end
end
