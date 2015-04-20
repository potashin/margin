class Client < ActiveRecord::Base
	belongs_to :client_type
	has_many :items
	has_many :orders
	has_many :asset_discounts, through: :client_type

	devise :database_authenticatable, :registerable#, :validatable

	def get_item_portfolio

		# Hash for storing portfolio items' quantity and market price
		@positions = Hash.new do |hash, key| hash[key] = Hash.new(0) end

		# Hash for storing portfolio main margin indexes
		@portfolio = Hash.new(0)

		self.items.joins(:market).select('items.*', 'asset_prices.last as market').each do |v|
			# Get the net count for current asset position
			net = v[:quantity] * (v[:item_status_type_id] != 2 ? 1 : -1)

			# Get market price and convert to RUB
			@positions[v[:asset_id]][:price] = v[:market]

			# Calculate total net count per asset
			@positions[v[:asset_id]][:quantity] += net

			# Calculate price for the total net count
			@positions[v[:asset_id]][:total] +=  net * @positions[v[:asset_id]][:price]
		end

		# Get discounts for the payment instruments that are used to purchase not liquid assets ("RUB" currency is excluded)
		discounts = self.asset_discounts.joins(asset: :orders)
			            .where(orders: {order_state_type_id: 1}, assets: {asset_type_id: 2})
			            .where.not(asset_id: 3).index_by(&:asset_id)

		# Iterating through orders to batch assets in Ka/Kl collections
		self.orders
				.active
				.joins(:asset,
				       :market,
				       :currency,
				       :order_price_type,
				       :order_status_type)
				.select('orders.*',
				        'assets.liquid',
				        'asset_prices.last as market',
				        'currencies_orders.last as currency',
				        'order_price_types.id as price_type',
				        'order_status_types.id as status_type')
				.each do |v|

			# Calculate the order price:
			#   1. take market price when
			#			1.1. such is chosen by client
			#			1.2. purchase order has custom price greater than market
			#			1.3. sale order has custom price less than market
			#   2. otherwise take client's custom price
			order_price = v[:currency] * if v[:price_type] == 1 or
																		( v[:status_type] == 1 and v[:price] > v[:market] ) or
																		( v[:status_type] == 2 and v[:price] < v[:market] )
										                  v[:market]
										               else
																			v[:price]
										               end

			# Check if price is maximum/minimum for sale/purchase correspondingly
			if v[:status_type] == 1 and (@positions[v[:asset_id]][:price_plus] > order_price or @positions[v[:asset_id]][:price_plus] == 0)
				@positions[v[:asset_id]][:price_plus] = order_price
			elsif v[:status_type] == 2 and @positions[v[:asset_id]][:price_plus] < order_price
				@positions[v[:asset_id]][:price_minus] = order_price
			end

			# Fill in market price
			unless @positions[v[:asset_id]][:price] > 0 then @positions[v[:asset_id]][:price] = v[:market] * v[:currency] end

			if v[:liquid]
				# Asset is liquid

				# Swap Ka and Kl collections on the order type condition
				col1, col2 = v[:status_type] == 1 ? %w(ka kl) :  %w(kl ka)

				# Batch assets in collections
				@positions[v[:asset_id]][:"#{col1}_quantity"] += v[:quantity]
				@positions[v[:payment_instrument_id]][:"#{col2}_quantity"] += v[:quantity] * order_price
				@positions[v[:asset_id]][:"#{col1}_total"] += v[:quantity] * order_price
				@positions[v[:payment_instrument_id]][:"#{col2}_total"] += v[:quantity] * order_price

				# Calculate additional risk if currency different from RUB
				if v[:payment_instrument_id] != 3
					# Sale order
					if v[:status_type] == 2
						@positions[v[:payment_instrument_id]][:additional_risk_plus] += @positions[v[:payment_instrument_id]][:kl_total] *
							[@positions[v[:asset_id]][:price_plus] * (1 - discounts[v[:payment_instrument_id]][:d0_plus]) - order_price, 0].max
					# Purchase order
					elsif v[:status_type] == 1
						@positions[v[:payment_instrument_id]][:additional_risk_minus] += @positions[v[:payment_instrument_id]][:ka_total] *
							[order_price - @positions[v[:asset_id]][:price_minus] * (1 + discounts[v[:payment_instrument_id]][:d0_minus]), 0].max
					end
				end
			else
				# Asset isn't liquid, add it to it's payment instrument Qnm collection
				@positions[v[:payment_instrument_id]][:not_liquid] += v[:quantity] * order_price
			end

		end

		# Get discounts for all items in the portfolio and orders
		discounts = self.asset_discounts.where(asset_id: @positions.keys ).index_by(&:asset_id)

		@positions.each  do |asset, data|
			# Find minimum and maximum price for each item
			@positions[asset][:price_plus] = data[:price_plus] > 0 ? [data[:price], data[:price_plus]].min : data[:price]
			@positions[asset][:price_minus] = [data[:price], data[:price_minus]].max

			# Calculate minimum and maximum total price for each item
			@positions[asset][:s_plus] = (data[:quantity] + data[:ka_quantity] - data[:not_liquid]) * data[:price_plus]
			@positions[asset][:s_minus] = (data[:quantity] - data[:kl_quantity] - data[:not_liquid])  * data[:price_minus]

			# Calculate risks for each minimum and maximum item price
			@positions[asset][:risk_plus] = [data[:s_plus] * discounts[asset][:d0_plus],
			                                 -data[:s_plus] * discounts[asset][:d0_minus]].max
			@positions[asset][:risk_minus] = [data[:s_minus] * discounts[asset][:d0_plus],
			                                  -data[:s_minus] * discounts[asset][:d0_minus]].max

			# Calculate total risks
			@positions[asset][:total_risk_plus] = data[:total] - data[:s_plus] + data[:ka_total] + data[:risk_plus] + data[:additional_risk_plus]
			@positions[asset][:total_risk_minus] = data[:total] - data[:s_minus] - data[:kl_total] + data[:risk_minus] + data[:additional_risk_minus]

			# Total portfolio price
			@portfolio[:total] += data[:total]

			# Initial margin
			@portfolio[:m_initial] += [[-data[:total] * discounts[asset][:d0_minus], 0].max,
			                           [ data[:total] * discounts[asset][:d0_plus], 0].max].max
			# Minimum margin
			@portfolio[:m_minimum] += [[-data[:total] * discounts[asset][:dx_minus], 0].max,
			                           [ data[:total] * discounts[asset][:dx_plus], 0].max].max



			# Initial margin adjusted with orders
			@portfolio[:m_order] += [data[:total_risk_plus], data[:total_risk_minus]].max
		end

		# Append each margin index with default currency name (in which all calculations were made)
		@portfolio.each do |k, x| @portfolio[k] = "#{x.round(1)} RUB" end
	end
end