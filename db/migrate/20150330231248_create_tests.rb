class CreateTests < ActiveRecord::Migration
  def change
    create_table :client_types do |t|
			t.string :name, limit: 10, null: false
			t.text :description, limit: 50
    end
    add_index :client_types, :name, unique: true

    create_table :clients do |t|
	    t.string :login, limit: 20, null: false
	    t.string :first_name, limit: 20
	    t.string :last_name, limit: 30
	    t.string :email, limit: 40, null: false
	    t.string :encrypted_password, limit: 100, null: false
			t.integer :client_type_id, default: 1
	    t.timestamps null: false
    end
    add_index :clients, :email, unique: true
    add_index :clients, :login, unique: true
    add_foreign_key :clients, :client_types
  end
end
