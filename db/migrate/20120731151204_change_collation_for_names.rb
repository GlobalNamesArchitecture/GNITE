class ChangeCollationForNames < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE names MODIFY name_string VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL"
  end

  def self.down
    execute "ALTER TABLE names MODIFY name_string VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL"
  end
end
