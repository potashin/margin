class Order < ActiveRecord::Base
	belongs_to :client
	belongs_to :order_state_type
	belongs_to :order_price_type
	belongs_to :status_type

	attr_readonly :asset_id, :status_type_id

	def self.get_orders
		@orders = {}
		self.includes(:status_type).all.each do |v|
			(@orders[v.order_state_type_id.to_s] ||= []) << v
		end
		@orders
	end

	def order_to_item (quantity = nil)
		Order.transaction do
			shared_attributes = {
									client_id: self.client_id,
									asset_id: self.asset_id,
									payment_instrument_id: self.payment_instrument_id,
									price: self.price
								}

			@item = Item.new(shared_attributes)
			@item.status_type_id = if self.status_type_id == 'BUY' then 'REQUIREMENT' else 'OBLIGATION' end

			if quantity.nil?
				@item.quantity = self.quantity
			else
				@order = Order.new(shared_attributes.merge({
					                                           quantity: self.quantity - quantity,
				                                             status_type_id: self.status_type_id,
				                                             order_price_type_id: self.order_price_type_id
				                                           }))

				@order.save
				@item.quantity = quantity
			end

			self.update_attribute(:order_state_type_id, 'm')
			@item.save

		end

	end
end
