class Item < ActiveRecord::Base
	belongs_to :client
	belongs_to :asset
	belongs_to :item_status_type

	belongs_to :market,
	           -> { where payment_instrument_id: 3 },
	           class_name: 'AssetPrice', foreign_key: 'asset_id', primary_key: 'asset_id'

	def self.get_items
		items = {}
		self.includes(:asset, :item_status_type).each do |v|
			(items[v.item_status_type_id.to_i] ||= []) << v
		end
		items
	end

end