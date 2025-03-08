require "net/http"
require "json"
require "openai"

class ChatsController < ApplicationController
  def index
    @chats = Chat.all
  end

  def create
    user_message = params[:message]

    # Call OpenAI API
    ai_response = get_ai_response(user_message)

    @chat = Chat.create(message: user_message, response: ai_response)

    respond_to do |format|
      format.html { redirect_to chats_path }
    end
  end

  def ask
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    # Store user's message in DB
    user_message = current_user.messages.create!(role: "user", content: params[:message])
  
    response = client.chat(
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
    ai_message = current_user.messages.create!(role: "ai", content: ai_response)
    @ai_response = ai_response
    @token_usage = response.dig("usage")
  
    respond_to do |format|
      format.turbo_stream
    end
  end
  

  private

  def get_ai_response(user_message)
    api_key = ENV["OPENAI_API_KEY"] # Store key in Heroku config
    url = URI("https://api.openai.com/v1/chat/completions")

    response = Net::HTTP.post(
      url,
      { model: "gpt-4", messages: [{ role: "user", content: user_message }] }.to_json,
      { "Content-Type" => "application/json", "Authorization" => "Bearer #{api_key}" }
    )

    JSON.parse(response.body)["choices"].first["message"]["content"].strip
  rescue
    "Sorry, I couldn't process that request."
  end
end
