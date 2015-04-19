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

	validates :quantity,
	          presence: true,
	          numericality: { only_integer: true }

	attr_readonly :asset_id, :order_status_type_id

	def self.get_orders
		orders = {}
		self.includes(:asset, :payment_instrument, :order_status_type, :order_state_type).each do |v|
			(orders[v.order_state_type_id.to_i] ||= []) << v
		end
		orders
	end

	# Withdraw order (set state as withdrawn)
	def withdraw
		self.update_attribute(:order_state_type_id, 2)
	end

	# Execute order (set state as executed)
	def execute
		self.update_attribute(:order_state_type_id, 3)
		self
	end

	# Turn executed order into requirement and obligation
	def order_to_item (quantity = nil)
		Order.transaction do
			# If order is executed partially create a new order
			unless quantity.nil?
				# Create a new order from the existing one with the remaining quantity
				Order.create(self.attributes.merge(id: nil, quantity: self.quantity - quantity))
				# Update quantity of the current order
				self.quantity = quantity
			end

			# If order's price type is market get current market price
			if self.price.nil? then self.price = self.market.last * self.currency.last end

			# Each executed order is split into requirement and obligation
			item_attr = [{asset_id: self.asset_id, quantity: self.quantity },
			             {asset_id: self.payment_instrument_id, quantity: self.price * self.quantity }]

			# Find each item's status according to it's order status
			item_types = self.order_status_type_id == 1 ? [1, 2] : [2, 1]

			# Form items' hash, take items' status array as keys and items' data hash as corresponding elements
			Hash[item_types.zip(item_attr)].each do |type, attr|
				# Create items for the client of each type
				self.client.items.create(attr.merge({item_status_type_id: type, order_id: self.id}))
			end

			# Set current order as executed
			self.execute
		end
	end
end
