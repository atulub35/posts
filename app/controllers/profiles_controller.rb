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
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully"
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :avatar, :phone_number, :language, :timezone, :email, :password, :password_confirmation)
  end
end
