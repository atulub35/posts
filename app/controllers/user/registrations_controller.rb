# frozen_string_literal: true

class User::RegistrationsController < Devise::RegistrationsController
  layout 'devise'
  respond_to :html, :json, :turbo_stream
  protect_from_forgery with: :exception, unless: -> { request.format.json? || request.format.turbo_stream? }
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  protected

  def respond_with(resource, _opts = {})
    if resource.persisted?
      # Handle successful registration
      respond_to do |format|
        format.html { redirect_to root_path }
        format.turbo_stream { redirect_to root_path }
        format.json do
          render json: { 
            message: 'Registration successful',
            redirect_path: root_path
          }, status: :created
        end
      end
    else
      # Handle validation errors for turbo streams
      respond_to do |format|
        format.html { super }
        format.turbo_stream do
          error_messages = resource.errors.full_messages
          if error_messages.any?
            flash.now[:alert] = error_messages.to_sentence
          else
            flash.now[:alert] = "Registration failed. Please try again."
          end
          
          # flash_html = render_to_string(partial: "shared/flash/notification")
          render turbo_stream: turbo_stream.append("flash-notification", partial: "shared/flash/notification")
        end
        format.json do
          render json: { 
            errors: resource.errors.full_messages,
            status: :unprocessable_entity 
          }, status: :unprocessable_entity
        end
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
