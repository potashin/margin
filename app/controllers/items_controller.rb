class ItemsController < ApplicationController

	before_filter :authenticate_client!


  def index
	  @items = current_client.items.includes(:status_type).order(:status_type_id, :quantity)
  end

end
