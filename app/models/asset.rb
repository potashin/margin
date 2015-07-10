class Asset < ActiveRecord::Base

	scope :securities, -> { where asset_type_id: 1}
	scope :fx, -> { where asset_type_id: 2}
	belongs_to :asset_type
	has_many :asset_discounts
	has_many :assets, class_name: 'AssetPrice', foreign_key: 'asset_id'
	has_many :payment_instruments, class_name: 'AssetPrice', foreign_key: 'payment_instrument_id'
	has_many :orders, class_name: 'Order', foreign_key: 'payment_instrument_id'

end