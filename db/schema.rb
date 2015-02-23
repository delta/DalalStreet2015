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

ActiveRecord::Schema.define(version: 20150223112939) do

  create_table "banks", force: true do |t|
    t.integer  "user_id"
    t.integer  "stock_id"
    t.decimal  "pricerendered", precision: 10, scale: 0
    t.integer  "numofstock"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buys", force: true do |t|
    t.integer  "user_id"
    t.integer  "stock_id"
    t.decimal  "price",      precision: 10, scale: 0
    t.integer  "numofstock"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "stock_id"
    t.string   "log"
  end

  create_table "market_events", force: true do |t|
    t.integer  "stock_id"
    t.string   "eventname"
    t.integer  "event_type"
    t.integer  "event_turn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event"
    t.integer  "event_done"
  end

  create_table "messages", force: true do |t|
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.integer  "user_id"
    t.string   "notification"
    t.integer  "seen"
    t.integer  "notice_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sells", force: true do |t|
    t.integer  "user_id"
    t.integer  "stock_id"
    t.decimal  "priceexpected", precision: 10, scale: 0
    t.integer  "numofstock"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_useds", force: true do |t|
    t.integer  "user_id"
    t.integer  "stock_id"
    t.integer  "numofstock"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stocks", force: true do |t|
    t.string   "stockname"
    t.decimal  "currentprice",     precision: 8, scale: 3
    t.decimal  "dayhigh",          precision: 8, scale: 3
    t.decimal  "daylow",           precision: 8, scale: 3
    t.decimal  "alltimehigh",      precision: 8, scale: 3
    t.decimal  "alltimelow",       precision: 8, scale: 3
    t.integer  "stocksinexchange"
    t.integer  "stocksinmarket"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updown"
  end

  create_table "users", force: true do |t|
    t.string   "email",                                          default: "",      null: false
    t.string   "encrypted_password",                             default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                  default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.string   "username"
    t.decimal  "cash",                   precision: 8, scale: 3, default: 10000.0, null: false
    t.decimal  "total",                  precision: 8, scale: 3
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
