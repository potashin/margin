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

ActiveRecord::Schema.define(version: 20150404174157) do

  create_table "asset_discounts", force: :cascade do |t|
    t.integer  "asset_id"
    t.integer  "client_type_id"
    t.float    "d0_plus",        null: false
    t.float    "d0_minus",       null: false
    t.float    "dx_plus",        null: false
    t.float    "dx_minus",       null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "asset_discounts", ["asset_id", "client_type_id"], name: "index_asset_discounts_on_asset_id_and_client_type_id", unique: true

  create_table "asset_prices", force: :cascade do |t|
    t.integer  "asset_id"
    t.integer  "payment_instrument_id"
    t.float    "last",                  null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "asset_prices", ["asset_id", "payment_instrument_id"], name: "index_asset_prices_on_asset_id_and_payment_instrument_id", unique: true

  create_table "asset_types", force: :cascade do |t|
    t.string   "name",        limit: 20
    t.text     "description", limit: 100
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "asset_types", ["name"], name: "index_asset_types_on_name", unique: true

  create_table "assets", force: :cascade do |t|
    t.string   "name",          limit: 20,                 null: false
    t.text     "description",   limit: 100
    t.integer  "asset_type_id"
    t.boolean  "liquid",                    default: true
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "assets", ["name"], name: "index_assets_on_name", unique: true

  create_table "client_types", force: :cascade do |t|
    t.string "name",        limit: 10, null: false
    t.text   "description", limit: 50
  end

  add_index "client_types", ["name"], name: "index_client_types_on_name", unique: true

  create_table "clients", force: :cascade do |t|
    t.string   "login",              limit: 20,              null: false
    t.string   "first_name",         limit: 20
    t.string   "last_name",          limit: 30
    t.string   "email",              limit: 40,              null: false
    t.string   "encrypted_password", limit: 100,             null: false
    t.integer  "client_type_id",                 default: 1
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "clients", ["email"], name: "index_clients_on_email", unique: true
  add_index "clients", ["login"], name: "index_clients_on_login", unique: true

  create_table "item_status_types", force: :cascade do |t|
    t.string   "name",        limit: 20, null: false
    t.text     "description", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "item_status_types", ["name"], name: "index_item_status_types_on_name", unique: true

  create_table "items", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "asset_id"
    t.float    "quantity"
    t.integer  "item_status_type_id"
    t.boolean  "completed",           default: false
    t.integer  "order_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "order_price_types", force: :cascade do |t|
    t.string   "name",        limit: 20, null: false
    t.text     "description", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "order_price_types", ["name"], name: "index_order_price_types_on_name", unique: true

  create_table "order_state_types", force: :cascade do |t|
    t.string   "name",        limit: 20, null: false
    t.text     "description", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "order_state_types", ["name"], name: "index_order_state_types_on_name", unique: true

  create_table "order_status_types", force: :cascade do |t|
    t.string   "name",        limit: 20, null: false
    t.text     "description", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "order_status_types", ["name"], name: "index_order_status_types_on_name", unique: true

  create_table "orders", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "asset_id"
    t.integer  "payment_instrument_id", default: 3
    t.integer  "order_status_type_id"
    t.integer  "order_state_type_id",   default: 1
    t.integer  "order_price_type_id"
    t.float    "price"
    t.integer  "quantity"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

end
