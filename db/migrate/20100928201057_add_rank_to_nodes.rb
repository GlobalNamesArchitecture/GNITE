class AddRankToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :rank, :string
  end

  def self.down
    remove_column :nodes, :rank
  end
end
