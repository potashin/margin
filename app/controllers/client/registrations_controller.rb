class Client::RegistrationsController < Devise::RegistrationsController
	respond_to :html, :json
end