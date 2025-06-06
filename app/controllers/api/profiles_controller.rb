module Api
  class ProfilesController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
    respond_to :json

    def show
      @user = current_user
      render json: {
        status: { code: 200, message: 'Profile retrieved successfully' },
        user: {
          id: @user.id,
          email: @user.email,
          name: @user.name,
          phone_number: @user.phone_number,
          language: @user.language,
          timezone: @user.timezone,
          avatar_url: @user.avatar.attached? ? url_for(@user.avatar) : nil
        }
      }
    end

    def update
      Rails.logger.info "Received profile update request. Method: #{request.method}"
      Rails.logger.info "Content-Type: #{request.content_type}"
      Rails.logger.info "Parameters: #{params.inspect}"
      
      @user = current_user
      
      # Handle avatar removal if requested
      if params[:user] && (params[:user][:remove_avatar] == "1" || params[:user][:remove_avatar] == true)
        Rails.logger.info "Removing avatar attachment"
        @user.avatar.purge if @user.avatar.attached?
      end
      
      if @user.update(profile_params)
        Rails.logger.info "Profile updated successfully"
        render json: {
          status: { code: 200, message: 'Profile updated successfully' },
          user: {
            id: @user.id,
            email: @user.email,
            name: @user.name,
            phone_number: @user.phone_number,
            language: @user.language,
            timezone: @user.timezone,
            avatar_url: @user.avatar.attached? ? url_for(@user.avatar) : nil
          }
        }
      else
        Rails.logger.error "Failed to update profile: #{@user.errors.full_messages.join(', ')}"
        render json: {
          status: { code: 422, message: 'Failed to update profile' },
          errors: @user.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    private

    def profile_params
      permitted_params = params.require(:user).permit(:name, :avatar, :phone_number, :language, :timezone, :email)
      
      # Only include password params if they are present and not blank
      if params[:user][:password].present?
        permitted_params.merge!(params.require(:user).permit(:password, :password_confirmation))
      end
      
      permitted_params
    end
  end
end 