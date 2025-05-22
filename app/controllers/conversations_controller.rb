class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]

  def index
    @conversations = current_user.conversations.includes(:users, :messages).order(updated_at: :desc)
  end

  def show
    @conversation = Conversation.find(params[:id])
    unless @conversation.users.include?(current_user)
      redirect_to conversations_path, alert: "You don't have access to this conversation"
      return
    end
    
    @message = Message.new
    @messages = @conversation.messages.includes(:user).order(created_at: :asc)
    @other_user = @conversation.other_participant(current_user)
    @current_user_id = current_user.id
    
    # Update current user's status to online
    current_user.update_online_status
    
    # Let Hotwire know we're viewing this conversation
    Turbo::StreamsChannel.broadcast_replace_to(
      @conversation,
      target: "user_status_#{current_user.id}",
      partial: "user_statuses/status",
      locals: { user: current_user }
    )
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

  def new
    @users = User.where.not(id: current_user.id)
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