class OrderStatusType < ActiveRecord::Base
	has_many :orders
end