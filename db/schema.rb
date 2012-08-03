# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 3) do

  create_table "addresses", :force => true do |t|
    t.integer "addressable_id"
    t.string  "addressable_type"
    t.string  "street",           :null => false
    t.string  "city",             :null => false
    t.string  "zipcode"
    t.string  "country"
    t.string  "more"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], :name => "index_addresses_on_addressable_id_and_addressable_type"
  add_index "addresses", ["city"], :name => "index_addresses_on_city"
  add_index "addresses", ["zipcode"], :name => "index_addresses_on_zipcode"

  create_table "contacts", :force => true do |t|
    t.integer "contactable_id"
    t.string  "contactable_type"
    t.text    "contacts",         :null => false
  end

  add_index "contacts", ["contactable_id", "contactable_type"], :name => "index_contacts_on_contactable_id_and_contactable_type"

  create_table "cvs", :force => true do |t|
    t.integer  "expert_id",  :null => false
    t.string   "filename",   :null => false
    t.string   "language"
    t.text     "cv"
    t.datetime "created_at"
  end

  add_index "cvs", ["cv"], :name => "fulltext_cv"
  add_index "cvs", ["expert_id"], :name => "index_cvs_on_expert_id"
  add_index "cvs", ["filename"], :name => "index_cvs_on_filename"

  create_table "experts", :force => true do |t|
    t.integer  "user_id",                              :null => false
    t.string   "name",                                 :null => false
    t.string   "prename",                              :null => false
    t.string   "gender",                               :null => false
    t.string   "birthname"
    t.datetime "birthday"
    t.string   "birthplace"
    t.string   "citizenship"
    t.string   "degree"
    t.string   "marital_status", :default => "single", :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "experts", ["name"], :name => "index_experts_on_name"
  add_index "experts", ["prename"], :name => "index_experts_on_prename"
  add_index "experts", ["user_id"], :name => "index_experts_on_user_id"

  create_table "privileges", :force => true do |t|
    t.integer "user_id",                       :null => false
    t.boolean "admin",      :default => false, :null => false
    t.boolean "experts",    :default => false, :null => false
    t.boolean "partners",   :default => false, :null => false
    t.boolean "references", :default => false, :null => false
  end

  add_index "privileges", ["user_id"], :name => "index_privileges_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "username",        :null => false
    t.string   "email",           :null => false
    t.string   "password_digest", :null => false
    t.string   "login_hash"
    t.string   "name",            :null => false
    t.string   "prename",         :null => false
    t.datetime "created_at",      :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["login_hash"], :name => "index_users_on_login_hash"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
