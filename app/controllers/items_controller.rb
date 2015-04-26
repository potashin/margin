class ItemsController < ApplicationController

	before_action :authenticate_client!

	respond_to :html, :js

	def new
		@item = current_client.items.new
	end

	def create
		@item = current_client.items.find_by(asset_id: item_params[:asset_id], item_status_type_id: 3 )
		if @item
			@item.quantity += item_params[:quantity].to_f
		else
			@item = current_client.items.new(item_params)
			@item.item_status_type_id = 3
		end

		@code = @item.save
		notification 'Баланс успешно обновлен'
	end

	def destroy
		@item = current_client.items.find(params[:id])
		@code = @item.destroy
		notification 'Позиция успешно выведена из портфеля клиента'
	end

	private

	def notification message
		if @code
			(flash[:success] ||= []) << message
			render js: "window.location = '#{orders_path}'"
		else
			flash.now[:alert] = @item.errors.full_messages
			render partial: 'shared/notification'
		end
	end

	def item_params
		params.require(:item)
					.permit(:asset_id,
					        :quantity,
					        :item_status_type_id)
	end
end
