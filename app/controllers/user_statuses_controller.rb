class UserStatusesController < ApplicationController
  before_action :authenticate_user!
  # Allow requests from sendBeacon which might use different content types
  skip_before_action :verify_authenticity_token, only: [:publish], 
                     if: -> { request.content_type.in?(['text/plain', 'application/x-www-form-urlencoded']) }
  
  # POST /user_statuses/publish
  def publish
    Rails.logger.info("UserStatusesController#publish - params: #{params.inspect}")
    
    status = params[:status] || 'online'
    Rails.logger.info("Processing status update to: #{status}")
    
    case status
    when 'online'
      current_user.update_online_status
    when 'offline'
      current_user.update_offline_status
    when 'away'
      # For away status, update last_seen_at but don't change online_status
      current_user.update(last_seen_at: Time.current)
    end
    
    # Get the specific conversation if provided
    conversation_id = params[:conversation_id]
    
    if conversation_id.present?
      # Broadcast to a specific conversation
      conversation = current_user.conversations.find_by(id: conversation_id)
      if conversation
        broadcast_status_to_conversation(conversation, current_user)
        Rails.logger.info("Broadcasted status to conversation #{conversation_id}")
      else
        Rails.logger.warn("Conversation #{conversation_id} not found for user #{current_user.id}")
      end
    else
      # Broadcast to all conversations
      Rails.logger.info("Broadcasting to all conversations for user #{current_user.id}")
      current_user.conversations.each do |conversation|
        broadcast_status_to_conversation(conversation, current_user)
      end
    end
    
    respond_to do |format|
      format.html { head :ok }
      format.json { head :ok }
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace(
          "user_status_#{current_user.id}", 
          partial: "user_statuses/status", 
          locals: { user: current_user }
        )
      }
      format.all { head :ok }
    end
  end
  
  private
  
  def broadcast_status_to_conversation(conversation, user)
    other_user = conversation.other_participant(user)
    return unless other_user
    
    Rails.logger.info("Broadcasting status update for user #{user.id} to conversation #{conversation.id}")
    
    # Broadcast to the conversation's stream
    Turbo::StreamsChannel.broadcast_replace_to(
      conversation,
      target: "user_status_#{user.id}",
      partial: "user_statuses/status",
      locals: { user: user }
    )
  end
end
