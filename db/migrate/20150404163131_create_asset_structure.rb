class CreateAssetStructure < ActiveRecord::Migration
  def change
    create_table :asset_types do |t|
			t.string :name, limit: 20
			t.text :description, limit: 100
			t.timestamps null: false
    end
		add_index :asset_types, :name, unique: true

		create_table :assets do |t|
			t.string :name, limit: 20, null: false
			t.text :description, limit: 100
			t.integer :asset_type_id
			t.boolean :liquid, default: 1
			t.timestamps null: false
		end
    add_index :assets, :name, unique: true
		add_foreign_key :assets, :asset_types

    create_table :asset_discounts do |t|
	    t.integer :asset_id
	    t.integer :client_type_id
	    t.float :d0_plus, null: false
	    t.float :d0_minus, null: false
	    t.float :dx_plus, null: false
	    t.float :dx_minus, null: false
	    t.timestamps null: false
    end
    add_index :asset_discounts, [:asset_id, :client_type_id], unique: true
    add_foreign_key :asset_discounts, :assets
    add_foreign_key :asset_discounts, :client_types

    create_table :asset_prices do |t|
	    t.integer :asset_id
	    t.integer :payment_instrument_id
	    t.float :last, null: false
	    t.timestamps null: false
    end
    add_index :asset_prices, [:asset_id, :payment_instrument_id], unique: true
    add_foreign_key :asset_prices, :assets, column: :asset_id, primary_key: :id
    add_foreign_key :asset_prices, :assets, column: :payment_instrument_id, primary_key: :id

  end
end
