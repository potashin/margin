class Order < ActiveRecord::Base
	scope :active, -> { where order_state_type_id: 1}

	belongs_to :currency,
							-> { where payment_instrument_id: 3 },
							class_name: 'AssetPrice', foreign_key: 'payment_instrument_id', primary_key: 'asset_id'

	belongs_to :market,
	           -> (order){
			           if order.is_a? JoinDependency::JoinAssociation
				           where 'asset_prices.payment_instrument_id = orders.payment_instrument_id'
			           else
				           where payment_instrument_id: order.payment_instrument_id
			           end
	           },
							class_name: 'AssetPrice', foreign_key: 'asset_id', primary_key: 'asset_id'

	belongs_to :asset, class_name: 'Asset'
	belongs_to :payment_instrument, class_name: 'Asset'
	belongs_to :client
	belongs_to :order_status_type
	belongs_to :order_state_type
	belongs_to :order_price_type

	attr_readonly :asset_id, :order_status_type_id

	def self.get_orders
		orders = {}
		self.includes(:order_status_type).each do |v|
			(orders[v.order_state_type_id.to_s] ||= []) << v
		end
		orders
	end

	def withdraw
		self.update_attribute(:order_state_type_id, 2)
	end

	def execute
		#self.update_attribute(:order_state_type_id, 3)
		self
	end

	def order_to_item (quantity = nil)
		Order.transaction do
			# Create a new order from the existing one
			unless quantity.nil?
				Order.create(self.attributes.merge(id: nil, quantity: self.quantity - quantity))
				self.quantity = quantity
			end


			if self.price.nil? then self.price = self.market.last * self.currency.last end

			# Each executed order is split into requirement and obligation
			item_attr = [{asset_id: self.asset_id, quantity: self.quantity },
			             {asset_id: self.payment_instrument_id, quantity: self.price * self.quantity }]

			item_types = self.order_status_type_id == 1 ? [1, 2] : [2, 1]

			Hash[item_types.zip(item_attr)].each do |type, attr|
				self.client.items.create(attr.merge({item_status_type_id: type, order_id: self.id}))
			end

			self.execute
		end
	end
end
