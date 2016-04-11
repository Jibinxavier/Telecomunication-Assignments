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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160401123343) do

  create_table "dropbox_files", force: :cascade do |t|
    t.string   "path"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "key"
  end

  add_index "dropbox_files", ["user_id"], name: "index_dropbox_files_on_user_id"

  create_table "share_files", force: :cascade do |t|
    t.integer  "shared_with_id"
    t.integer  "file_id"
    t.string   "encrypted_key"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "share_files", ["file_id", "shared_with_id"], name: "index_share_files_on_file_id_and_shared_with_id", unique: true
  add_index "share_files", ["file_id"], name: "index_share_files_on_file_id"
  add_index "share_files", ["shared_with_id"], name: "index_share_files_on_shared_with_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",           default: false
    t.string   "dropbox_session"
    t.string   "public_key"
    t.string   "private_key"
  end

end
