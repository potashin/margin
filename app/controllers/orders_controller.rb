class OrdersController < ApplicationController

	before_action :authenticate_client!,:all_orders, only: [:index, :create]
	respond_to :html, :js

	def new
		@order = current_client.orders.new
	end

	def create
		@order = current_client.orders.create(order_params)
		if @order.save
			render json: {data: @order.to_json , message: "Successfully created order.", class: 'success'}
		else
			render json: {message: @order.errors.full_messages, class: 'danger'}
		end
	end

	def destroy
		current_client.orders.find(params[:id]).destroy
		flash[:notice] = "Successfully destroyed order."
		render :nothing => true
	end

	def edit
		@order = Order.find(params[:id])
	end

	def update
		@order = current_client.orders.find(params[:id])
		if @order.update(order_params)
			render json: {data: @order.to_json , message: "Successfully updated order.", class: 'success'}
		else
			render json: {message: @order.errors.full_messages, class: 'error'}
		end
	end



	private

		def all_orders
			@orders = current_client.orders.includes(:status_type).all
		end

		def order_params
			params.require(:order).permit(:asset_id, :status_type_id, :price, :quantity, :payment_instrument_id )
		end
end
