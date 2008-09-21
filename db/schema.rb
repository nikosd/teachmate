# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 12) do

  create_table "comments", :force => true do |t|
    t.string   "body",       :limit => 10000
    t.integer  "user_id"
    t.integer  "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["user_id", "author_id"], :name => "index_comments_on_user_id_and_author_id", :unique => true

  create_table "learn_taggings", :force => true do |t|
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "search_queries", :force => true do |t|
    t.string "learn_string"
    t.string "teach_string"
  end

  add_index "search_queries", ["learn_string", "teach_string"], :name => "index_search_queries_on_learn_string_and_teach_string", :unique => true

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "search_query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["user_id", "search_query_id"], :name => "index_subscriptions_on_user_id_and_search_query_id", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "string",     :limit => 256
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teach_taggings", :force => true do |t|
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "first_name",                :limit => 32
    t.string   "second_name",               :limit => 32
    t.date     "birthdate"
    t.string   "city",                      :limit => 32
    t.string   "region",                    :limit => 32
    t.string   "country",                   :limit => 32
    t.string   "more_info"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hashed_password",           :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "openid"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "notes",                     :limit => 100
    t.string   "password_token",            :limit => 20
    t.datetime "password_token_expires"
    t.string   "avatar"
  end

  add_index "users", ["openid"], :name => "index_users_on_openid", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
