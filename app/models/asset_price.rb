class AssetPrice < ActiveRecord::Base
	# belongs_to :asset, class_name: 'Asset'
	# belongs_to :payment_instrument, class_name: 'Asset'

	has_many :asset_prices, class_name: 'Item', foreign_key: 'asset_id'
	has_many :payment_instrument_prices, class_name: 'Item', foreign_key: 'payment_instrument_id'
	has_many :assets, class_name: 'Order', foreign_key: 'asset_id'
	has_many :payment_instruments, class_name: 'Order', foreign_key: 'payment_instrument_id'
end