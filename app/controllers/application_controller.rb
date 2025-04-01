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
    if user_signed_in?
      super
    else
      # redirect_to new_user_session_path, :notice => 'You need to sign in first!'
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
      respond_to do |format|
        format.html { redirect_to new_user_session_path, notice: 'You need to sign in first!' }
        format.json { render json: { error: 'Unauthorized', message: 'You need to sign in first' }, status: :unauthorized }
      end
    end
  end
end
