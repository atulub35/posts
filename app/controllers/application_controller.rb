class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token, if: -> { json_request? || turbo_stream_request? }

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :update_user_status, if: :user_signed_in?

  include Pagy::Backend

  def after_sign_in_path_for(resource)
    profiles_show_path
  end

  protected

  def json_request?
    request.format.json?
  end
  
  def turbo_stream_request?
    request.format.turbo_stream?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:avatar, :name, :phone_number, :language, :timezone])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar, :name, :phone_number, :language, :timezone])
  end

  def update_user_status
    # Ensure we have a valid user before proceeding
    return unless current_user && current_user.id.present?
    
    # Only update if current session is not set or if last update was more than 1 minute ago
    last_seen_key = "user_#{current_user.id}_last_seen"
    
    begin
      last_update = session[last_seen_key] ? Time.parse(session[last_seen_key]) : nil
      
      if last_update.nil? || Time.now - last_update > 1.minute
        current_user.update_online_status
        session[last_seen_key] = Time.now.to_s
      end
    rescue => e
      # Handle any errors to prevent breaking the application flow
      Rails.logger.error("Failed to update user status: #{e.message}")
      # Reset the session key to force an update next time
      session[last_seen_key] = nil
    end
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
        format.turbo_stream { 
          flash.now[:alert] = 'You need to sign in first!'
          render turbo_stream: turbo_stream.replace(
            "flash-notification", 
            partial: "shared/flash/notification", 
            locals: { flash: flash }
          )
        }
      end
    end
  end

  # Safer check for Turbo Frames
  def turbo_user_signed_in?
    begin
      user_signed_in?
    rescue => e
      false
    end
  end

  # For Active Storage URLs in development
  def default_url_options
    if Rails.env.development?
      {
        host: request.host_with_port || 'localhost:3000'
      }
    else
      {}
    end
  end
end
