class ClientType < ActiveRecord::Base
	has_many :clients
	has_many :asset_discounts

end
