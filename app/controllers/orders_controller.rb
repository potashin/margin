class OrdersController < ApplicationController

	before_action :authenticate_client!
	before_action :order, only: [:edit, :update, :withdraw, :execute_full, :execute_partial]

	respond_to :html, :js

	def new
		@order = current_client.orders.new
		render partial: 'orders/modal'
	end


	def edit
		render partial: 'orders/modal'
	end

	def index
		@items = current_client.items.includes(:asset, :item_status_type).active.group_by(&:item_status_type_id)
		@orders = current_client.orders.includes(:asset, :payment_instrument).group_by(&:order_state_type_id)
		@order_types = OrderStateType.all
		@item_types = ItemStatusType.all
	end

	def create
		@order = current_client.orders.new(order_params)
		@code = @order.save
		notification 'Создано новое поручение'
	end

	def withdraw
		@code = @order.withdraw
		notification 'Поручение успешно снято'
	end

	def execute_full
		@code = @order.order_to_item()
		notification 'Поручение выполнено полностью'
	end

	def execute_partial
		@code = @order.order_to_item(rand 1...@order.quantity)
		notification 'Поручение выполнено частично'
	end

	def update
		@code = @order.update(order_params)
		notification 'Поручение успешно отредактировано'
	end

	private

		def notification message
			if @code
				(flash[:success] ||= []) << message
				render js: "window.location = '#{orders_path}'"
			else
				flash.now[:alert] = @order.errors.full_messages
				render partial: 'shared/notification'
			end
		end

		def order
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
