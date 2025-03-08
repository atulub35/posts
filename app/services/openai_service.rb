require "openai"

class OpenAIService
  def initialize
    @client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai, :api_key))
  end

  def chat(prompt)
    response = @client.chat(
      parameters: {
        model: "gpt-4-turbo", # or "gpt-3.5-turbo"
        messages: [{ role: "user", content: prompt }]
      }
    )

    response.dig("choices", 0, "message", "content")
  end
end
