class RefactorTreeTable < ActiveRecord::Migration
  def self.up
    add_column :trees, :revision, :string
    remove_column :trees, :user_id
    add_index :trees, [:revision, :id], name: :index_trees_on_revision_and_id
  end

  def self.down
    remove_index :trees, name: :index_trees_on_revision_and_id
    add_column :trees, :user_id, :integer
    remove_column :trees, :revision
  end
end
