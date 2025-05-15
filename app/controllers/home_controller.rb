class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def index
    if user_signed_in?
      @stats = {
        posts_count: current_user.posts.count,
        chat_messages_count: current_user.messages.ai_chat.count,
        private_messages_count: current_user.messages.user_chat.count,
        conversations_count: Conversation.joins(:conversation_participants)
                                        .where(conversation_participants: { user_id: current_user.id })
                                        .distinct.count,
        image_generations_count: current_user.messages.where("content LIKE ?", "%image%").count
      }
      
      # Get the most recent conversation
      @recent_conversation = Conversation.joins(:conversation_participants)
                                         .where(conversation_participants: { user_id: current_user.id })
                                         .order(updated_at: :desc)
                                         .first
    end
    
    render
  end
end