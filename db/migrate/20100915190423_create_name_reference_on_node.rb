class CreateNameReferenceOnNode < ActiveRecord::Migration
  def self.up
    remove_column :nodes ,:name
    add_column  :nodes   ,:name_id ,:integer ,null: false

    add_index   :nodes   ,:name_id
  end

  def self.down
    remove_column :nodes, :name_id
    add_column    :nodes, :name, :string
  end
end
