class OrdersController < ApplicationController

	before_action :authenticate_client!
	before_action :get_orders_by_state, only: [:index, :create]
	before_action :get_order_by_id, only: [:edit, :update, :withdraw, :execute_full, :execute_partial]

	respond_to :html, :js

	def new
		@order = current_client.orders.new
	end

	def create
		@order = current_client.orders.create(order_params)
		@code = @order.save
		raise_notification
	end

	def withdraw
		@code = @order.update(order_state_type_id: 'w')
		raise_notification
	end

	def execute_full
		@code = @order.order_to_item()
		raise_notification
	end

	def execute_partial
		@code = @order.order_to_item(rand 1...@order.quantity)
		raise_notification
	end

	def update
		@code = @order.update(order_params)
		raise_notification
	end

	private

		def get_orders_by_state
			@items = current_client.items.all
			@orders = current_client.orders.get_orders
			@order_types = OrderStateType.where(id: @orders.keys).all
		end

		def raise_notification
			if @code
				render json: {data: @order.to_json , message: 'Success', class: 'success'}
			else
				render json: {message: @order.errors.full_messages, class: 'error'}
			end
		end

		def get_order_by_id
			@order = current_client.orders.find(params[:id])
		end

		def order_params
			params.require(:order).permit(:asset_id, :status_type_id, :price, :quantity, :payment_instrument_id, :order_state_type_id )
		end
end
