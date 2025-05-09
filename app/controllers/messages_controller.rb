class MessagesController < ApplicationController
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper
  
  before_action :authenticate_user!, unless: -> { turbo_frame_request? }
  before_action :set_conversation

  def create
    @message = @conversation.messages.build(message_params)
    @message.user = current_user if turbo_user_signed_in?
    @message.user_id = current_user.id if @message.user_id.nil? && turbo_user_signed_in?
    
    # Ensure a valid role is set
    @message.role = 'user' unless @message.role.present? && @message.role.in?(%w[user assistant])

    if @message.save
      # Broadcast a neutral message that each client will style appropriately
      broadcast_message_to_conversation(@message)
      
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation) }
        format.turbo_stream { 
          # For the sender, just return success - the broadcast will handle the display
          head :ok
        }
      end
    else
      error_message = @message.errors.full_messages.to_sentence
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation), alert: error_message || 'Message could not be sent.' }
        format.turbo_stream { 
          flash.now[:alert] = error_message || 'Message could not be sent.'
          flash_html = render_to_string(partial: "shared/flash/notification")
          render turbo_stream: turbo_stream.replace("flash-notification", html: flash_html)
        }
      end
    end
  end

  private

  def broadcast_message_to_conversation(message)
    # Use turbo_stream.append instead of directly broadcasting HTML
    # This ensures proper Turbo Stream events are triggered
    html = <<~HTML
      <div class="message" 
           data-message-id="#{message.id}" 
           data-sender-id="#{message.user_id}"
           data-chat-scroll-target="message">
        <div class="message-content rounded-3 p-3" data-sender="#{message.user_id}">
          <div class="d-flex align-items-center mb-1">
            #{render_avatar_html(message.user)}
            <small>
              #{message.user ? (message.user.name || message.user.email) : "Unknown User"}
            </small>
          </div>
          <p class="mb-0">#{sanitize(message.content)}</p>
          <small>
            #{time_ago_in_words(message.created_at)} ago
          </small>
        </div>
      </div>
    HTML

    # Broadcast in a way that triggers proper events
    Turbo::StreamsChannel.broadcast_append_to(
      message.conversation,
      target: "messages_container",
      html: html,
      # Add these attributes to ensure the stream is properly processed
      attributes: {
        "data-scrollable": "true",
        "data-chat-message": "true"
      }
    )
  end
  
  def render_avatar_html(user)
    if user&.avatar&.attached?
      "<span class=\"rounded-circle me-2 d-inline-block\" style=\"width: 24px; height: 24px; background-color: #ccc;\"></span>"
    else
      "<div class=\"rounded-circle bg-secondary d-flex align-items-center justify-content-center me-2\" style=\"width: 24px; height: 24px;\"><i class=\"bx bx-user text-white\"></i></div>"
    end
  end

  def turbo_frame_request?
    request.headers["Turbo-Frame"].present?
  end
  
  def render_message_html(message, current_user_id = nil)
    # Manually build the HTML for the message to avoid Warden dependency
    # Use the passed user_id instead of current_user to avoid Warden
    sender_is_current_user = message.user_id == current_user_id
    css_class = sender_is_current_user ? 'message-sent' : 'message-received'
    content_class = sender_is_current_user ? 'bg-primary text-white' : 'bg-body-tertiary'
    text_class = sender_is_current_user ? 'text-white-50' : 'text-muted'
    
    user_name = message.user ? (message.user.name || message.user.email) : "Unknown User"
    time_text = "#{time_ago_in_words(message.created_at)} ago"
    
    # Use sanitize to escape HTML in message content
    content = sanitize(message.content)
    
    # Build avatar HTML
    avatar_html = render_avatar_html(message.user)
    
    <<~HTML
      <div class="message #{css_class}">
        <div class="message-content #{content_class} rounded-3 p-3">
          <div class="d-flex align-items-center mb-1">
            #{avatar_html}
            <small class="#{text_class}">#{user_name}</small>
          </div>
          <p class="mb-0">#{content}</p>
          <small class="#{text_class}">#{time_text}</small>
        </div>
      </div>
    HTML
  end

  def set_conversation
    if turbo_user_signed_in?
      @conversation = current_user.conversations.find(params[:conversation_id])
    elsif turbo_frame_request?
      # For Turbo Frame requests without authentication, redirect using Turbo Stream
      respond_to do |format|
        format.turbo_stream { 
          flash_html = render_to_string(partial: "shared/flash/notification", 
                                        locals: { flash: { alert: "Please sign in to continue" } })
          render turbo_stream: turbo_stream.replace("flash-notification", html: flash_html)
        }
      end
    else
      redirect_to new_user_session_path, alert: "Please sign in to continue"
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to conversations_path, alert: 'Conversation not found.' }
      format.turbo_stream { 
        flash.now[:alert] = 'Conversation not found.'
        flash_html = render_to_string(partial: "shared/flash/notification")
        render turbo_stream: turbo_stream.replace("flash-notification", html: flash_html)
      }
    end
  end

  def message_params
    params.require(:message).permit(:content, :role)
  end
end 