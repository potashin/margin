class Client < ActiveRecord::Base
	has_many :items
	has_many :orders
	devise :database_authenticatable, :registerable, :validatable
end