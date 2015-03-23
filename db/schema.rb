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

ActiveRecord::Schema.define(version: 20150125020643) do

  create_table "asset_discounts", primary_key: "asset_id", force: :cascade do |t|
    t.string "client_type_id", limit: 10, null: false
    t.float  "DoPLUS"
    t.float  "DoMINUS"
    t.float  "DxPLUS"
    t.float  "DxMINUS"
  end

  add_index "asset_discounts", ["asset_id", "client_type_id"], name: "sqlite_autoindex_asset_discounts_1", unique: true

  create_table "asset_prices", primary_key: "asset_id", force: :cascade do |t|
    t.string "payment_instrument_id", limit: 20, null: false
    t.float  "last"
  end

  add_index "asset_prices", ["asset_id", "payment_instrument_id"], name: "sqlite_autoindex_asset_prices_1", unique: true

  create_table "asset_types", force: :cascade do |t|
    t.text "description"
  end

  add_index "asset_types", ["id"], name: "sqlite_autoindex_asset_types_1", unique: true

# Could not dump table "assets" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

# Could not dump table "client_types" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

  create_table "clients", force: :cascade do |t|
    t.string "login",              limit: 15
    t.string "name",               limit: 50
    t.string "surname",            limit: 50
    t.string "email",              limit: 50
    t.string "encrypted_password", limit: 100,                  null: false
    t.string "client_type_id",     limit: 100, default: "KSUR"
  end

  add_index "clients", ["login"], name: "sqlite_autoindex_clients_1", unique: true

# Could not dump table "item_per_collection_list" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

# Could not dump table "item_per_collection_total" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

  create_table "items", force: :cascade do |t|
    t.integer "client_id",                        null: false
    t.string  "asset_id",              limit: 20, null: false
    t.string  "payment_instrument_id", limit: 20
    t.string  "status_type_id",        limit: 20, null: false
    t.float   "price"
    t.integer "quantity"
  end

# Could not dump table "marginal_prices" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

  create_table "order_price_types", force: :cascade do |t|
    t.text "description"
  end

  add_index "order_price_types", ["id"], name: "sqlite_autoindex_order_price_types_1", unique: true

  create_table "order_state_types", force: :cascade do |t|
    t.text "description"
  end

  add_index "order_state_types", ["id"], name: "sqlite_autoindex_order_state_types_1", unique: true

  create_table "orders", force: :cascade do |t|
    t.integer "client_id",                                           null: false
    t.string  "asset_id",              limit: 20,                    null: false
    t.string  "payment_instrument_id", limit: 20
    t.string  "status_type_id",        limit: 20,                    null: false
    t.float   "price"
    t.integer "quantity"
    t.string  "order_state_type_id",   limit: 1,  default: "o"
    t.string  "order_price_type_id",   limit: 20, default: "MARKET"
  end

# Could not dump table "portfolio_items_totals" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

# Could not dump table "portfolios" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

# Could not dump table "price_spreads" because of following NoMethodError
#   undefined method `[]' for nil:NilClass

  create_table "status_types", force: :cascade do |t|
    t.text "description"
  end

  add_index "status_types", ["id"], name: "sqlite_autoindex_status_types_1", unique: true

end
