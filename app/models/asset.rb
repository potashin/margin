class Asset < ActiveRecord::Base
	has_many :asset_discount
	has_many :asset_prices
end