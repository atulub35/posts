# frozen_string_literal: true

class User::SessionsController < Devise::SessionsController
  layout 'devise'
  respond_to :html, :json, :turbo_stream
  protect_from_forgery with: :exception, unless: -> { request.format.json? || request.format.turbo_stream? }
  # Temporarily skip updating user status during sign-in/out to avoid conflicts
  skip_before_action :update_user_status, only: [:create, :destroy]
  # Skip CSRF verification for Turbo Stream requests from the login form
  skip_before_action :verify_authenticity_token, if: -> { request.format.turbo_stream? }
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    # Explicitly authenticate with warden
    self.resource = warden.authenticate!(auth_options)
    
    # Sign in the user
    sign_in(resource_name, resource)
    
    # Manually update status after successful login
    if resource.respond_to?(:update_online_status)
      begin
        resource.update_online_status 
        # Store in session to avoid immediate updates
        session["user_#{resource.id}_last_seen"] = Time.now.to_s
      rescue => e
        Rails.logger.error("Failed to update status on login: #{e.message}")
      end
    end
    
    yield resource if block_given?

    respond_to do |format|
      format.html { redirect_to after_sign_in_path_for(resource) }
      format.turbo_stream { redirect_to after_sign_in_path_for(resource) }
      format.json { 
        @resource = resource
        @redirect_path = after_sign_in_path_for(resource)
        render 'create'
      }
    end
  end

  # DELETE /resource/sign_out
  def destroy
    # Store the user before signing out
    user_to_update = current_user
    
    # Sign out first
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    
    # Mark as offline after signing out if possible
    if user_to_update && user_to_update.respond_to?(:update_offline_status)
      begin
        user_to_update.update_offline_status
      rescue => e
        Rails.logger.error("Failed to update offline status on logout: #{e.message}")
      end
    end
    
    yield if block_given?

    respond_to do |format|
      format.html { redirect_to after_sign_out_path_for(resource_name) }
      format.turbo_stream { redirect_to after_sign_out_path_for(resource_name) }
      format.json { 
        @redirect_path = after_sign_out_path_for(resource_name)
        render 'destroy'
      }
    end
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private
  def respond_with(resource, _opts = {})
    if request.format.json? 
      render json: { message: 'Logged in successfully', user: resource }, status: :ok
    end
  end

  def respond_to_on_destroy
    if request.format.json? 
      render json: { 
        message: "Logged out successfully",
        redirect_path: after_sign_out_path_for(resource_name)
      }, status: :ok
    end
  end

  # def respond_with(resource, _opts = {})
  #   if request.format.json?
  #     @resource = resource
  #     @redirect_path = after_sign_in_path_for(resource)
  #     render 'create'
  #   else
  #     super
  #   end
  # end

  # def respond_to_on_destroy
  #   if request.format.json?
  #     @redirect_path = after_sign_out_path_for(resource_name)
  #     render 'destroy'
  #   else
  #     super
  #   end
  # end
end
