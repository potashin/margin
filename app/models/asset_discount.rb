class AssetDiscount < ActiveRecord::Base
	belongs_to :asset
	belongs_to :client_type
end