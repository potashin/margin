class Item < ActiveRecord::Base
	belongs_to :client
	belongs_to :asset
	belongs_to :item_status_type
	belongs_to :market,
	           -> do where payment_instrument_id: 3 end,
	           class_name: 'AssetPrice', foreign_key: 'asset_id', primary_key: 'asset_id'
	scope :active,
	      -> do where completed: 0 end

	def self.get_items
		items = {}
		self.includes(:asset, :item_status_type).active.each do |v|
			(items[v.item_status_type_id.to_i] ||= []) << v
		end
		items
	end
end