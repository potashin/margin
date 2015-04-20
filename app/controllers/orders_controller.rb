class OrdersController < ApplicationController

	before_action :authenticate_client!
	before_action :get_orders_by_state, only: [:index, :create]
	before_action :get_order, only: [:edit, :update, :withdraw, :execute_full, :execute_partial]

	respond_to :html, :js

	def new
		@order = current_client.orders.new
		render partial: 'orders/modal'
	end

	def edit
		render partial: 'orders/modal'
	end

	def create
		@order = current_client.orders.new(order_params)
		@code = @order.save
		raise_notification 'Создано новое поручение'
	end

	def withdraw
		@code = @order.withdraw
		raise_notification 'Поручение успешно снято'
	end

	def execute_full
		@code = @order.order_to_item()
		raise_notification 'Поручение выполнено полностью'
	end

	def execute_partial
		@code = @order.order_to_item(rand 1...@order.quantity)
		raise_notification 'Поручение выполнено частично'
	end

	def update
		@code = @order.update(order_params)
		raise_notification 'Поручение успешно отредактировано'
	end

	private

		def get_orders_by_state
			@items = current_client.items.get_items
			@orders = current_client.orders.get_orders
			@order_types = OrderStateType.all
			@item_types = ItemStatusType.all
		end

		def raise_notification message
			if @code
				(flash[:success] ||= []) << message
				render js: "window.location = '#{orders_path}'"
			else
				flash.now[:alert] = @order.errors.full_messages
				render partial: 'shared/notification'
			end
		end

		def get_order
			@order = current_client.orders.find(params[:id])
		end

		def order_params
			params.require(:order)
						.permit(:asset_id,
                    :order_price_type_id,
                    :price,
                    :quantity,
                    :payment_instrument_id,
                    :order_status_type_id)
		end
end
