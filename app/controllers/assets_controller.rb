class AssetsController < ApplicationController

  def new

  end

  def index
    @securities = Asset.all.joins(:asset_prices).where(asset_type_id: 1).select('assets.*, asset_prices.last,asset_prices.payment_instrument_id')
    @fx = Asset.all.joins(:asset_prices).where(asset_type_id: 2).select('assets.*, asset_prices.last,asset_prices.payment_instrument_id')
  end

  def show
    @asset = Asset.find(params[:id])
  end

  def edit
  end

  def delete
  end

  private

  def assets_params
    params.require(:asset).permit(:id, :description, :is_liquid, :asset_type_id)
  end
end
