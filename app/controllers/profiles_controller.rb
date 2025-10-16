class ProfilesController < ApplicationController
  respond_to :html, :json
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    respond_to do |format|
      if @user.update(profile_params)
        format.html { redirect_to profile_path, notice: "Profile updated successfully" }
        format.json { render json: { user: @user }, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: { error: @user.errors.full_messages.first }, status: :unprocessable_entity }
      end
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :avatar, :remove_avatar, :phone_number, :language, :timezone, :email, :password, :password_confirmation)
  end
end
