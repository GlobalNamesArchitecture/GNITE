class AddMetadataToTree < ActiveRecord::Migration
  def self.up
    add_column :trees, :uuid, :string
    add_column :trees, :publication_date, :datetime
    add_column :trees, :citation, :string
    add_column :trees, :abstract, :text
    add_column :trees, :creative_commons, :string
  end

  def self.down
    remove_column :trees, :uuid
    remove_column :trees, :publication_date
    remove_column :trees, :citation
    remove_column :trees, :abstract
    remove_column :trees, :creative_commons
  end
end
