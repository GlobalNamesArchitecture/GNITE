# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110615145727) do

  create_table "action_commands", :force => true do |t|
    t.string   "type"
    t.integer  "user_id"
    t.boolean  "undo"
    t.integer  "node_id"
    t.integer  "parent_id"
    t.integer  "destination_node_id"
    t.integer  "destination_parent_id"
    t.string   "old_name"
    t.string   "new_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "json_message"
    t.integer  "tree_id"
  end

  add_index "action_commands", ["tree_id"], :name => "index_action_commands_on_tree_id"

  create_table "bookmarks", :force => true do |t|
    t.integer  "node_id",                                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bookmark_title", :limit => 128, :default => "", :null => false
  end

  add_index "bookmarks", ["node_id"], :name => "index_bookmarks_on_node_id"

  create_table "gnaclr_importer_logs", :force => true do |t|
    t.integer  "reference_tree_id"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gnaclr_importer_logs", ["reference_tree_id"], :name => "index_gnaclr_importer_logs_on_reference_tree_id"

  create_table "gnaclr_importers", :force => true do |t|
    t.integer  "reference_tree_id"
    t.string   "url"
    t.integer  "status"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gnaclr_publishers", :force => true do |t|
    t.integer  "master_tree_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gnaclr_publishers", ["master_tree_id"], :name => "index_gnaclr_publishers_on_master_tree_id"

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.string   "iso_639_1"
    t.string   "iso_639_2"
    t.string   "iso_639_3"
    t.string   "native"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "languages", ["iso_639_1"], :name => "index_languages_on_iso_639_1"

  create_table "master_tree_contributors", :force => true do |t|
    t.integer  "master_tree_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "master_tree_contributors", ["user_id", "master_tree_id"], :name => "index_master_tree_contributors_on_user_id_and_master_tree_id", :unique => true

  create_table "merge_decisions", :force => true do |t|
    t.string "label"
  end

  create_table "merge_events", :force => true do |t|
    t.integer  "master_tree_id"
    t.integer  "primary_node_id"
    t.integer  "secondary_node_id"
    t.integer  "user_id"
    t.string   "memo"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "merge_events", ["master_tree_id"], :name => "index_merge_events_on_master_tree_id"

  create_table "merge_result_primaries", :force => true do |t|
    t.integer  "merge_event_id"
    t.integer  "node_id"
    t.string   "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merge_result_secondaries", :force => true do |t|
    t.integer  "merge_result_primary_id"
    t.integer  "node_id"
    t.integer  "merge_type_id"
    t.integer  "merge_subtype_id"
    t.string   "path"
    t.integer  "merge_decision_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "merge_result_secondaries", ["merge_decision_id"], :name => "index_merge_results_secondaries_2"
  add_index "merge_result_secondaries", ["merge_type_id", "merge_subtype_id"], :name => "index_merge_results_secondaries_1"

  create_table "merge_subtypes", :force => true do |t|
    t.string "label"
  end

  create_table "merge_types", :force => true do |t|
    t.string "label"
  end

  create_table "names", :force => true do |t|
    t.string   "name_string", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "names", ["name_string"], :name => "index_names_on_name_string", :unique => true

  create_table "nodes", :force => true do |t|
    t.integer  "tree_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "name_id",    :null => false
    t.string   "rank"
    t.string   "local_id"
    t.integer  "parent_id"
  end

  add_index "nodes", ["local_id", "tree_id"], :name => "index_nodes_on_local_id_and_tree_id", :unique => true
  add_index "nodes", ["name_id"], :name => "index_nodes_on_name_id"
  add_index "nodes", ["parent_id"], :name => "index_nodes_on_parent_id"
  add_index "nodes", ["tree_id"], :name => "index_nodes_on_tree_id"

  create_table "redo_action_commands", :force => true do |t|
    t.integer  "master_tree_id"
    t.integer  "action_command_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redo_action_commands", ["master_tree_id", "action_command_id"], :name => "index_redo_action_commands_on_master_tree_and_action_command"

  create_table "reference_tree_collections", :force => true do |t|
    t.integer  "reference_tree_id"
    t.integer  "master_tree_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reference_tree_collections", ["master_tree_id", "reference_tree_id"], :name => "index_rtc_on_master_tree_id_etc", :unique => true

  create_table "synonyms", :force => true do |t|
    t.integer  "node_id"
    t.integer  "name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  add_index "synonyms", ["node_id", "name_id"], :name => "index_synonyms_on_node_id_and_name_id", :unique => true

  create_table "trees", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uuid"
    t.datetime "publication_date"
    t.string   "citation"
    t.text     "abstract"
    t.string   "creative_commons"
    t.integer  "master_tree_id"
    t.string   "type"
    t.string   "state",            :default => "active", :null => false
    t.string   "revision"
  end

  add_index "trees", ["revision", "id"], :name => "index_trees_on_revision_and_id"

  create_table "undo_action_commands", :force => true do |t|
    t.integer  "master_tree_id"
    t.integer  "action_command_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "undo_action_commands", ["master_tree_id", "action_command_id"], :name => "index_undo_action_commands_on_master_tree_and_action_command"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.string   "remember_token",     :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

  create_table "vernacular_names", :force => true do |t|
    t.integer  "node_id"
    t.integer  "name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language_id"
    t.string   "locality"
  end

  add_index "vernacular_names", ["node_id", "name_id"], :name => "index_vernacular_names_on_node_id_and_name_id", :unique => true

end
