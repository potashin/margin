module ApplicationHelper

	def alert_class_for(flash_type)
		{
			:success => 'alert-success',
			:error => 'alert-danger',
			:alert => 'alert-warning',
			:notice => 'alert-info'
		}[flash_type.to_sym] || flash_type.to_s
	end

	def portfolio
		@portfolio ||= Portfolio.find_by(client_id: current_client.id)
			               .attributes
			               .inject({}) do |h, (k, v)|
											if v.nil?
												h[k.to_sym] = 'Не определено'
											else
												h[k.to_sym] = "#{v.round} RUB"
											end
											h
										end
	end
end
