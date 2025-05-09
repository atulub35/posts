class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]

  def index
    @conversations = current_user.conversations.includes(:users, :messages).order(updated_at: :desc)
  end

  def show
    @messages = @conversation.messages.includes(:user).order(created_at: :asc)
    @message = Message.new
    
    # Store the current user's ID to avoid Warden dependency in views
    @current_user_id = current_user.id if current_user
    
    # Find the other user for the conversation header
    @other_user = @conversation.other_participant(current_user)
  end

  def create
    other_user = User.find(params[:user_id])
    @conversation = find_or_create_conversation(current_user, other_user)

    respond_to do |format|
      format.html { redirect_to conversation_path(@conversation) }
      format.json { render json: @conversation }
      format.turbo_stream { redirect_to conversation_path(@conversation) }
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def find_or_create_conversation(user1, user2)
    # First, try to find an existing conversation between these users
    conversation = Conversation.joins(:conversation_participants)
                             .where(conversation_participants: { user_id: [user1.id, user2.id] })
                             .group('conversations.id')
                             .having('COUNT(DISTINCT conversation_participants.user_id) = 2')
                             .first

    # If no conversation exists, create a new one with both users
    unless conversation
      # Use a transaction to ensure both users are added
      Conversation.transaction do
        conversation = Conversation.create!
        ConversationParticipant.create!(conversation: conversation, user: user1)
        ConversationParticipant.create!(conversation: conversation, user: user2)
      end
    end

    conversation
  end
end 