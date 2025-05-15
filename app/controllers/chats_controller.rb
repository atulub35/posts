require "net/http"
require "json"
require "openai"

class ChatsController < ApplicationController
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :authenticate_user!
  before_action :setup_openai_client
  before_action :verify_api_key

  def index
    @messages = current_user.ai_messages.order(created_at: :asc)
    @message = Message.new(role: 'user')
    
    respond_to do |format|
      format.html
      format.json { render json: @messages }
    end
  end

  def create
    user_message = params[:message]
    ai_response = get_ai_response(user_message)
    @chat = Chat.create(message: user_message, response: ai_response)

    respond_to do |format|
      format.html { redirect_to chats_path }
      format.json { render json: @chat }
    end
  end

  def destroy
    current_user.ai_messages.destroy_all
    
    respond_to do |format|
      format.html { redirect_to chats_path, notice: 'Chat history cleared successfully' }
      format.json { head :no_content }
    end
  end

  def ask
    # Store user's message in DB
    user_message = current_user.messages.create!(role: "user", content: params[:message])
   
    response = @openai_client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "user", content: params[:message] }
        ],
        max_tokens: 100
      }
    )
   
    ai_response = response.dig("choices", 0, "message", "content")
   
    # Store AI's response in DB
    @message = current_user.messages.create!(role: "assistant", content: ai_response)
    @ai_response = ai_response
    @token_usage = response.dig("usage")
   
    respond_to do |format|
      format.turbo_stream
      format.json { 
        render json: {
          ai_response: @ai_response,
          token_usage: @token_usage,
          message: @message
        }
      }
    end
  rescue OpenAI::Error => e
    Rails.logger.error "OpenAI API Error: #{e.message}"
    @error_message = "Sorry, there was an error processing your request. Please try again."
    respond_to do |format|
      format.turbo_stream
      format.json { render json: { error: @error_message }, status: :unprocessable_entity }
    end
  end

  private

  def setup_openai_client
    api_key = Rails.application.credentials.dig(:openai, :api_key) || ENV["OPENAI_API_KEY"]
    
    if api_key.blank?
      Rails.logger.error "OpenAI API Key is missing in both credentials and environment variables"
      raise "OpenAI API Key is not configured"
    end

    @openai_client = OpenAI::Client.new
  rescue => e
    Rails.logger.error "Failed to setup OpenAI client: #{e.message}"
    @error_message = "Failed to initialize AI service. Please check your configuration."
    respond_to do |format|
      format.turbo_stream
      format.html
      format.json { render json: { error: @error_message }, status: :unprocessable_entity }
    end
  end

  def verify_api_key
    api_key = Rails.application.credentials.dig(:openai, :api_key) || ENV["OPENAI_API_KEY"]
    
    if api_key.blank?
      Rails.logger.error "OpenAI API Key is missing"
      @error_message = "OpenAI API Key is not configured. Please check your credentials or environment variables."
      respond_to do |format|
        format.turbo_stream
        format.html
        format.json { render json: { error: @error_message }, status: :unprocessable_entity }
      end
    elsif !api_key.start_with?("sk-")
      Rails.logger.error "OpenAI API Key format is invalid"
      @error_message = "OpenAI API Key format is invalid. Please check your API key."
      respond_to do |format|
        format.turbo_stream
        format.html
        format.json { render json: { error: @error_message }, status: :unprocessable_entity }
      end
    end
  end

  def get_ai_response(user_message)
    response = @openai_client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: user_message }]
      }
    )
    response.dig("choices", 0, "message", "content").strip
  rescue OpenAI::Error => e
    Rails.logger.error "OpenAI API Error: #{e.message}"
    "Sorry, I couldn't process that request."
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
