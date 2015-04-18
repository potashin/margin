class CreateOrderStructure < ActiveRecord::Migration
  def change
	  create_table :order_state_types do |t|
		  t.string :name, limit: 20, null: false
		  t.text :description, limit: 50
		  t.timestamps null: false
	  end
	  add_index :order_state_types, :name, unique: true

	  create_table :order_price_types do |t|
		  t.string :name, limit: 20, null: false
		  t.text :description, limit: 50
		  t.timestamps null: false
	  end
	  add_index :order_price_types, :name, unique: true

	  create_table :order_status_types do |t|
		  t.string :name, limit: 20, null: false
		  t.text :description, limit: 50
		  t.timestamps null: false
	  end
	  add_index :order_status_types, :name, unique: true

	  create_table :orders do |t|
		  t.integer :client_id, null: false
		  t.integer :asset_id, null: false
		  t.integer :payment_instrument_id, default: 3
		  t.integer :order_status_type_id, null: false
		  t.integer :order_state_type_id, default: 1
		  t.integer :order_price_type_id, null: false
		  t.float :price
		  t.integer :quantity, null: false
		  t.timestamps null: false
	  end
	  add_foreign_key :orders, :asset_prices, column: :asset_id, primary_key: :asset_id
	  add_foreign_key :orders, :asset_prices, column: :payment_instrument_id, primary_key: :payment_instrument_id
	  add_foreign_key :orders, :order_status_types
	  add_foreign_key :orders, :order_price_types
	  add_foreign_key :orders, :order_state_types
	  add_foreign_key :orders, :clients
  end
end
