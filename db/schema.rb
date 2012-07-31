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

ActiveRecord::Schema.define(:version => 20120731151204) do

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

  create_table "controlled_terms", :force => true do |t|
    t.integer  "controlled_vocabulary_id"
    t.string   "name"
    t.string   "identifier"
    t.string   "uri"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "controlled_terms", ["controlled_vocabulary_id"], :name => "index_controlled_terms_on_controlled_vocabulary_id"

  create_table "controlled_vocabularies", :force => true do |t|
    t.string   "name"
    t.string   "identifier"
    t.string   "uri"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "controlled_vocabularies", ["identifier"], :name => "index_controlled_vocabularies_on_identifier", :unique => true

  create_table "gnaclr_importers", :force => true do |t|
    t.integer  "reference_tree_id"
    t.string   "url"
    t.integer  "status"
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

  create_table "jobs_logs", :force => true do |t|
    t.integer  "tree_id"
    t.string   "job_type"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs_logs", ["tree_id"], :name => "index_jobs_logs_on_tree_id"

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

  create_table "master_tree_logs", :force => true do |t|
    t.integer  "master_tree_id"
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "merge_tree_id"
  end

  add_index "merge_events", ["master_tree_id"], :name => "index_merge_events_on_master_tree_id"

  create_table "merge_result_primaries", :force => true do |t|
    t.integer  "merge_event_id"
    t.integer  "node_id"
    t.text     "path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merge_result_secondaries", :force => true do |t|
    t.integer  "merge_result_primary_id"
    t.integer  "node_id"
    t.integer  "merge_type_id"
    t.integer  "merge_subtype_id"
    t.text     "path"
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

  add_index "nodes", ["local_id", "tree_id"], :name => "index_nodes_on_local_id_and_tree_id"
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

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "rosters", :force => true do |t|
    t.integer  "master_tree_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rosters", ["master_tree_id", "user_id"], :name => "index_rosters_on_master_tree_id_and_user_id"

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
    t.integer  "user_id"
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
    t.string   "encrypted_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "given_name",             :limit => 128
    t.string   "surname",                :limit => 128
    t.string   "affiliation"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

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
