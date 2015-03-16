class Order < ActiveRecord::Base
	belongs_to :client
	belongs_to :status_type
end
