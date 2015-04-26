module ApplicationHelper

	def alert_class_for(flash_type)
		{
			:success => 'alert-success',
			:error => 'alert-danger',
			:alert => 'alert-warning',
			:notice => 'alert-info'
		}[flash_type.to_sym] || flash_type.to_s
	end

	def label_class_for(flash_type)
		{
			1 => 'label-success',
			2 => 'label-info',
			3 => 'label-warning',
			4 => 'label-danger',
			5 => 'label-default',
		}[flash_type.to_i]
	end

	protected

	def portfolio
		@portfolio = current_client.get_item_portfolio
	end
end
