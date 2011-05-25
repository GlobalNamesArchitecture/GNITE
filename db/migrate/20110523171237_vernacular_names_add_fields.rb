class VernacularNamesAddFields < ActiveRecord::Migration
  def self.up
    change_table :vernacular_names do |t|
      t.references :language
      t.string :locality
    end
  end

  def self.down
    change_table :vernacular_names do |t|
      t.remove :locality, :language_id
    end
  end
end
