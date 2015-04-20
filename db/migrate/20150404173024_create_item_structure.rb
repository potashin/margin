class CreateItemStructure < ActiveRecord::Migration
  def change

    create_table :item_status_types do |t|
	    t.string :name, limit: 20, null: false
	    t.text :description, limit: 50
	    t.timestamps null: false
    end
    add_index :item_status_types, :name, unique: true

    create_table :items do |t|
	    t.integer :client_id
	    t.integer :asset_id
	    t.float :quantity
	    t.integer :item_status_type_id
	    t.integer :completed, default: 0
	    t.integer :order_id
	    t.timestamps null: false
    end
    add_foreign_key :items, :asset_prices
    add_foreign_key :items, :item_status_types
    add_foreign_key :items, :orders
    add_foreign_key :items, :clients
  end
end
