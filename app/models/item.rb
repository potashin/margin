class Item < ActiveRecord::Base
	belongs_to :client
	belongs_to :item_status_type
	# belongs_to :asset_price, class_name: 'AssetPrice', foreign_key: 'asset_id', primary_key: 'asset_id'
	# belongs_to :payment_instrument_price,
	#            -> { where payment_instrument_id: 3 },
	#            class_name: 'AssetPrice', foreign_key: 'payment_instrument_id', primary_key: 'asset_id'

	belongs_to :market,
	           -> { where payment_instrument_id: 3 },
	           class_name: 'AssetPrice', foreign_key: 'asset_id', primary_key: 'asset_id'

	belongs_to :asset, class_name: 'Asset'
	belongs_to :payment_instrument, class_name: 'Asset'


	def self.get_items
		items = {}
		self.includes(:item_status_type, :asset).all.each do |v|
			(items[v.item_status_type_id.to_s] ||= []) << v
		end
		items
	end

end