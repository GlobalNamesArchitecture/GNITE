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

ActiveRecord::Schema.define(:version => 20101005162708) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "ancestry"
    t.integer  "name_id",    :null => false
    t.string   "rank"
  end

  add_index "nodes", ["ancestry"], :name => "index_nodes_on_ancestry"
  add_index "nodes", ["name_id"], :name => "index_nodes_on_name_id"
  add_index "nodes", ["tree_id"], :name => "index_nodes_on_tree_id"

  create_table "synonyms", :force => true do |t|
    t.integer  "node_id"
    t.integer  "name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "synonyms", ["node_id", "name_id"], :name => "index_synonyms_on_node_id_and_name_id", :unique => true

  create_table "trees", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "uuid"
    t.datetime "publication_date"
    t.string   "citation"
    t.text     "abstract"
    t.string   "creative_commons"
    t.integer  "master_tree_id"
    t.string   "type"
    t.string   "state",            :default => "active", :null => false
    t.string   "source_id"
  end

  add_index "trees", ["source_id"], :name => "index_trees_on_source_id"

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
  end

  add_index "vernacular_names", ["node_id", "name_id"], :name => "index_vernacular_names_on_node_id_and_name_id", :unique => true

end
