class ImagesController < ApplicationController

  def index
    @generated_images = session[:generated_images] || []
  end
  
  def create
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])

    begin
      # Handle reference image if uploaded
      reference_image = params[:reference_image]
      prompt = params[:prompt]
      
      if reference_image.present?
        Rails.logger.info "Processing reference image: #{reference_image.original_filename}"
        Rails.logger.info "Content type: #{reference_image.content_type}"
        
        # Validate file size (max 10MB)
        if reference_image.size > 10.megabytes
          raise StandardError, "Image file size must be less than 10MB"
        end
        
        # Validate content type
        unless reference_image.content_type.start_with?('image/')
          raise StandardError, "File must be an image"
        end

        # Convert the uploaded image to base64
        image_data = Base64.strict_encode64(reference_image.read)
        prompt = "#{prompt} (Reference image style)"
        Rails.logger.info "Successfully processed reference image"
      end

      Rails.logger.info "Sending request to OpenAI with prompt: #{prompt}"
      response = client.images.generate(
        parameters: {
          model: "dall-e-3",
          prompt: prompt,
          n: 1,
          size: "1024x1024"
        }
      )

      if response["data"].present?
        @image_url = response.dig("data", 0, "url")
        # Store in session for history
        session[:generated_images] ||= []
        session[:generated_images].unshift({
          url: @image_url,
          prompt: prompt,
          created_at: Time.current
        })
        # Keep only last 10 images
        session[:generated_images] = session[:generated_images].first(10)
      else
        Rails.logger.error "Invalid response from OpenAI: #{response.inspect}"
        raise StandardError, "Invalid response from OpenAI"
      end

    rescue OpenAI::Error => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      @error_message = "OpenAI API Error: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "Error processing image: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @error_message = "Error: #{e.message}"
    end

    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end
end
