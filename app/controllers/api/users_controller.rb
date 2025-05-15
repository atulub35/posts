module Api
  class UsersController < ApplicationController
    before_action :authenticate_user!, except: [:avatar]
    
    def avatar
      user = User.find_by(id: params[:id])
      
      if user&.avatar&.attached?
        render json: {
          avatar_url: helpers.s3_presigned_url(user.avatar),
          initials: user.name.present? ? user.name.first.upcase : user.email.first.upcase
        }
      else
        # Return initials for placeholder
        initials = user ? (user.name.present? ? user.name.first.upcase : user.email.first.upcase) : "?"
        render json: { 
          avatar_url: nil,
          initials: initials
        }
      end
    end
    
    def status
      user = User.find(params[:id])
      render json: { status: user.status }
    end
  end
end 