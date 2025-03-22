# frozen_string_literal: true

class User::SessionsController < Devise::SessionsController
  layout 'devise'
  respond_to :html, :json
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?

    respond_to do |format|
      format.html { redirect_to after_sign_in_path_for(resource) }
      format.json { 
        @resource = resource
        @redirect_path = after_sign_in_path_for(resource)
        render 'create'
      }
    end
  end

  # DELETE /resource/sign_out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    yield if block_given?

    respond_to do |format|
      format.html { redirect_to after_sign_out_path_for(resource_name) }
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
      @resource = resource
      @redirect_path = after_sign_in_path_for(resource)
      render 'create'
    else
      super
    end
  end

  def respond_to_on_destroy
    if request.format.json?
      @redirect_path = after_sign_out_path_for(resource_name)
      render 'destroy'
    else
      super
    end
  end
end
