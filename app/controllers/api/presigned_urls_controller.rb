module Api
  class PresignedUrlsController < ApplicationController
    before_action :authenticate_user!
    
    def show
      message = Message.find_by(id: params[:message_id])
      
      if message.nil?
        render json: { error: "Message not found" }, status: :not_found
        return
      end
      
      # Check if user has access to this message
      conversation = message.conversation
      unless conversation.users.include?(current_user)
        render json: { error: "Unauthorized" }, status: :unauthorized
        return
      end
      
      if message.image.attached?
        render json: {
          url: helpers.s3_presigned_url(message.image),
          content_type: message.image.content_type,
          filename: message.image.filename.to_s,
          byte_size: message.image.byte_size
        }
      else
        render json: { error: "No image attached" }, status: :not_found
      end
    end
  end
end 