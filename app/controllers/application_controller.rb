class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    profiles_show_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:avatar, :name, :phone_number, :language, :timezone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar, :name, :phone_number, :language, :timezone])
  end

  def authenticate_user!
    if request.format.json?
      if user_signed_in?
        super
      else
        render json: { error: 'You need to sign in first!' }, status: :unauthorized
      end
    else
      super
    end
  end
end
