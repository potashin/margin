class ItemsController < ApplicationController

	before_filter :authenticate_client!

	respond_to :html, :js

	def new
		@item = current_client.items.new
	end

	def create
		@item = current_client.items.new(item_params)
		@item.item_status_type_id = 3
		@code = @item.save
		notification  'Позиция успешно добавлена'
	end

	def destroy
		@item = current_client.items.find(params[:id])
		@code = @item.destroy
		notification  'Позиция успешно ликвидирована'
	end

	def notification(message)
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
