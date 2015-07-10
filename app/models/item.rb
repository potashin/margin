class Item < ActiveRecord::Base
	belongs_to :client
	belongs_to :asset
	belongs_to :item_status_type
	belongs_to :market,
	           -> do where payment_instrument_id: 3 end,
	           class_name: 'AssetPrice', foreign_key: 'asset_id', primary_key: 'asset_id'
	scope :active,
	      -> do where completed: 0 end

	validates :completed, inclusion: { in: [0,1] }
	validates :quantity,
	          presence: true,
	          numericality: true

	validates :client_id, :asset_id, :item_status_type_id, presence: true, allow_blank: false

end
