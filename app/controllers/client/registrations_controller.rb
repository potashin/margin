class Client::RegistrationsController < Devise::RegistrationsController
	respond_to :html, :json

	def sign_up_params
		params.require(:client).permit(:email, :password, :password_confirmation, :login, :first_name, :last_name)
	end
end