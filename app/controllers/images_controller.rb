class ImagesController < ApplicationController

  def index 
    
  end
  
  def create
    client = OpenAI::Client.new(access_token: Rails.env.production? ? ENV["OPENAI_API_KEY"] : Rails.application.credentials.dig(:openai, :api_key))

    begin
      response = client.images.generate(
        parameters: {
          model: "dall-e-3",
          prompt: params[:prompt],
          n: 1,
          size: "1024x1024"
        }
      )

      if response["data"].present?
        @image_url = response.dig("data", 0, "url")
      else
        raise StandardError, "Invalid response from OpenAI"
      end

    rescue OpenAI::Error => e
      @error_message = "OpenAI API Error: #{e.message}"
    rescue StandardError => e
      @error_message = "Something went wrong. Please try again later."
    end

    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end
end
