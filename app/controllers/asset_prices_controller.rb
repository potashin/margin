require 'open-uri'
require 'json'

class AssetPricesController < ApplicationController
	include ActionController::Live

	before_action :set_sse, :set_securities

	Market_URL = "http://moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities.json?iis.meta=off&iss.only=marketdata,dataversion&marketdata.columns=SECID,LAST"
	#FX_URL = "http://moex.com/iss/engines/currency/markets/selt/boards/CETS/securities.json?iis.meta=off&iss.only=marketdata,dataversion&marketdata.columns=SECID,LAST"

	def security_prices
		sse = SSE.new(response.stream, retry: 300, event: 'update')
		begin
			loop do
				data = JSON.parse(open(Market_URL.concat("&marketdata.securities=#{@sec_arg}&dataversion.seqnum=#{@sec_seqnum}")).read)
				if @sec_seqnum < data['dataversion']['data'][0][1] and data['marketdata']['data'].any?
					@sec_seqnum = data['dataversion']['data'][0][1]
					data['marketdata']['data'].each do |price|
						unless @securities.key? price[1]
							set_securities
						end
						unless price[1].nil? or @securities[price[0]].assets.first.last == price[1].to_f
							@securities[price[0]].assets.first.update_attribute(:last, price[1])
							sse.write(price)
						end
					end
				end
			end
		rescue IOError
		ensure response.stream.close
		end
		render nothing: true
	end

	private

	def set_sse
		response.headers['Content-Type'] = 'text/event-stream'
		@sec_seqnum = 0
		@fx_seqnum = 0
	end

	def set_securities
		assets = Asset.includes(:assets).securities
		@sec_arg = assets.pluck(:name).join(',')
		@securities = assets.index_by(&:name)
	end
end
