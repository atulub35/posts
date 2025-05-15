class ImagesController < ApplicationController
  before_action :authenticate_user!, unless: -> { turbo_frame_request? }
  respond_to :html, :json

  def index
    # We're not storing images in session anymore
    @generated_images = []

    respond_to do |format|
      format.html
      format.json
    end
  end

  def create
    client = OpenAI::Client.new

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
        # session[:generated_images] ||= []
        # session[:generated_images].unshift({
        #   id: Time.current.to_i,
        #   url: @image_url,
        #   prompt: prompt,
        #   created_at: Time.current
        # })
        # # Keep only last 10 images
        # session[:generated_images] = session[:generated_images].first(10)

        respond_to do |format|
          format.html
          format.turbo_stream { }
          format.json { render :create, status: :created }
        end
      else
        Rails.logger.error "Invalid response from OpenAI: #{response.inspect}"
        raise StandardError, "Invalid response from OpenAI"
      end

    rescue OpenAI::Error => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      Rails.logger.error "Error type: #{e.class}"
      Rails.logger.error "Error backtrace: #{e.backtrace.join("\n")}" if e.backtrace
      
      # Try to extract additional error details if available
      if e.respond_to?(:http_status) && e.respond_to?(:http_body)
        Rails.logger.error "HTTP Status: #{e.http_status}"
        Rails.logger.error "HTTP Body: #{e.http_body}"
      end
      
      flash[:alert] = "OpenAI API Error: #{e.message}"
      respond_to do |format|
        format.html { redirect_to images_path, alert: "OpenAI API Error: #{e.message}" }
        format.turbo_stream { }
        format.json { render json: { status: { code: 422, message: "OpenAI API Error: #{e.message}" }}, status: :unprocessable_entity }
      end
    rescue StandardError => e
      Rails.logger.error "Error processing image: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      respond_to do |format|
        format.html { redirect_to images_path, alert: e.message }
        format.turbo_stream { }
        format.json { render json: { status: { code: 422, message: e.message }}, status: :unprocessable_entity }
      end
    end
  end

  def new_variant
    # Form for house image variants
    respond_to do |format|
      format.html
    end
  end

  def variants
    # Create client with explicit configuration for project keys
    client = OpenAI::Client.new(
      access_token: ENV["OPENAI_API_KEY"],
      organization_id: ENV["OPENAI_ORGANIZATION_ID"]
    )
    
    # Log API credentials (mask sensitive parts)
    api_key = ENV["OPENAI_API_KEY"]
    masked_key = api_key.present? ? "#{api_key[0..5]}...#{api_key[-5..-1]}" : "not set"
    org_id = ENV["OPENAI_ORGANIZATION_ID"]
    masked_org = org_id.present? ? "#{org_id[0..5]}...#{org_id[-5..-1]}" : "not set"
    
    Rails.logger.info "OpenAI client created with:"
    Rails.logger.info "API Key: #{masked_key}"
    Rails.logger.info "Organization ID: #{masked_org}"

    begin
      # Handle house image upload
      house_image = params[:house_image]
      painting_style = params[:painting_style]
      
      unless house_image.present?
        raise StandardError, "Please upload a house image"
      end
      
      Rails.logger.info "Processing house image: #{house_image.original_filename}"
      Rails.logger.info "Content type: #{house_image.content_type}"
      Rails.logger.info "File size: #{house_image.size} bytes"
      
      # Validate file size (max 10MB)
      if house_image.size > 10.megabytes
        raise StandardError, "Image file size must be less than 10MB"
      end
      
      # Validate content type
      unless house_image.content_type.start_with?('image/')
        raise StandardError, "File must be an image"
      end

      # Convert the uploaded image to base64
      image_base64 = Base64.strict_encode64(house_image.read)
      Rails.logger.info "Image successfully converted to base64"
      
      # Prepare prompt for GPT-4 analysis
      gpt_prompt = "This is a house image. Please describe this house in detail focusing on architectural features. " + 
                  "Then suggest how it would look if painted in #{painting_style || 'a different artistic style'}."
      
      Rails.logger.info "Sending request to OpenAI GPT-4o with vision capabilities"
      
      # First use GPT-4 to analyze the image
      gpt_response = client.chat(
        parameters: {
          model: "gpt-4o",
          messages: [
            {
              role: "user",
              content: [
                { type: "text", text: gpt_prompt },
                {
                  type: "image_url",
                  image_url: {
                    url: "data:#{house_image.content_type};base64,#{image_base64}"
                  }
                }
              ]
            }
          ],
          max_tokens: 1000
        }
      )
      
      # Extract GPT-4's description and suggestion
      gpt_analysis = gpt_response.dig("choices", 0, "message", "content")
      
      Rails.logger.info "Successfully received GPT-4 analysis"
      Rails.logger.info "Analysis length: #{gpt_analysis.to_s.length} characters"
      
      # Create DALL-E prompt using GPT-4's analysis
      dalle_prompt = "Generate a painted variation of this house: #{gpt_analysis}"
      Rails.logger.info "Generated DALL-E prompt based on image analysis"
      
      # Now use DALL-E to generate the painted variation
      Rails.logger.info "Sending request to DALL-E for image generation"
      dalle_response = client.images.generate(
        parameters: {
          model: "dall-e-3",
          prompt: dalle_prompt,
          n: 1,
          size: "1024x1024",
          quality: "standard",
          style: "vivid"
        }
      )
      
      Rails.logger.info "DALL-E API response received"

      if dalle_response["data"].present?
        @image_url = dalle_response.dig("data", 0, "url")
        @original_image_data = "data:#{house_image.content_type};base64,#{image_base64}"
        @analysis = gpt_analysis
        
        # Don't store in session to avoid bloat

        # Simply respond with the appropriate format
        if request.format.html?
          render :variants
        elsif request.format.turbo_stream?
          # Just render the turbo_stream template that has the correct format
          render :variants
        elsif request.format.json?
          render json: { 
            status: { code: 200, message: "Success" }, 
            data: {
              variant_image_url: @image_url,
              analysis: @analysis
            }
          }
        end
      else
        Rails.logger.error "Invalid response from OpenAI: #{dalle_response.inspect}"
        raise StandardError, "Invalid response from OpenAI"
      end

    rescue OpenAI::Error => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      Rails.logger.error "Error type: #{e.class}"
      Rails.logger.error "Error backtrace: #{e.backtrace.join("\n")}" if e.backtrace
      
      # Try to extract additional error details if available
      if e.respond_to?(:http_status) && e.respond_to?(:http_body)
        Rails.logger.error "HTTP Status: #{e.http_status}"
        Rails.logger.error "HTTP Body: #{e.http_body}"
      end
      
      flash[:alert] = "OpenAI API Error: #{e.message}"
      
      if request.format.html?
        redirect_to images_path
      elsif request.format.turbo_stream?
        render turbo_stream: turbo_stream.update("main_content", html: render_to_string(partial: "shared/error", locals: { message: e.message }))
      elsif request.format.json?
        render json: { status: { code: 422, message: "OpenAI API Error: #{e.message}" }}, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error "Error processing house image: #{e.message}"
      Rails.logger.error "Error type: #{e.class}"
      Rails.logger.error e.backtrace.join("\n") if e.backtrace
      
      # Try to extract additional error details if available
      if defined?(e.http_status) && defined?(e.http_body)
        Rails.logger.error "HTTP Status: #{e.http_status}"
        Rails.logger.error "HTTP Body: #{e.http_body}"
      end
      
      flash[:alert] = e.message
      
      if request.format.html?
        redirect_to images_path
      elsif request.format.turbo_stream?
        render turbo_stream: turbo_stream.update("main_content", html: render_to_string(partial: "shared/error", locals: { message: e.message }))
      elsif request.format.json?
        render json: { status: { code: 422, message: e.message }}, status: :unprocessable_entity
      end
    end
  end

  def destroy
    # Since we're not storing in session, this method will need modification in the future
    # to handle persistent storage
    
    respond_to do |format|
      format.html { redirect_to images_path, notice: "Image was successfully deleted." }
      format.json { render :destroy }
    end
  end

  def test_api
    # Create client with explicit configuration for project keys
    client = OpenAI::Client.new(
      access_token: ENV["OPENAI_API_KEY"],
      organization_id: ENV["OPENAI_ORGANIZATION_ID"]
    )
    
    # Log API credentials (mask sensitive parts)
    api_key = ENV["OPENAI_API_KEY"]
    masked_key = api_key.present? ? "#{api_key[0..5]}...#{api_key[-5..-1]}" : "not set"
    org_id = ENV["OPENAI_ORGANIZATION_ID"]
    masked_org = org_id.present? ? "#{org_id[0..5]}...#{org_id[-5..-1]}" : "not set"
    
    Rails.logger.info "OpenAI client created with:"
    Rails.logger.info "API Key: #{masked_key}"
    Rails.logger.info "Organization ID: #{masked_org}"

    begin
      # Make a simple API call to validate credentials
      response = client.models.list
      
      render json: {
        status: "success",
        message: "OpenAI API connection successful",
        models_count: response["data"]&.length || 0,
        credentials: {
          api_key_present: api_key.present?,
          organization_id_present: org_id.present?
        }
      }
    rescue OpenAI::Error => e
      Rails.logger.error "OpenAI API Error: #{e.message}"
      render json: {
        status: "error",
        message: "OpenAI API Error: #{e.message}",
        credentials: {
          api_key_present: api_key.present?,
          organization_id_present: org_id.present?
        }
      }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "Error in test_api: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: {
        status: "error",
        message: e.message,
        credentials: {
          api_key_present: api_key.present?,
          organization_id_present: org_id.present?
        }
      }, status: :unprocessable_entity
    end
  end

  def debug_vision
    client = OpenAI::Client.new(
      access_token: ENV["OPENAI_API_KEY"],
      organization_id: ENV["OPENAI_ORGANIZATION_ID"]
    )
    
    # Log API credentials (mask sensitive parts)
    api_key = ENV["OPENAI_API_KEY"]
    masked_key = api_key.present? ? "#{api_key[0..5]}...#{api_key[-5..-1]}" : "not set"
    org_id = ENV["OPENAI_ORGANIZATION_ID"]
    masked_org = org_id.present? ? "#{org_id[0..5]}...#{org_id[-5..-1]}" : "not set"
    
    Rails.logger.info "OpenAI client created with:"
    Rails.logger.info "API Key: #{masked_key}"
    Rails.logger.info "Organization ID: #{masked_org}"

    begin
      # Handle house image upload
      house_image = params[:house_image]
      
      unless house_image.present?
        raise StandardError, "Please upload a house image"
      end
      
      Rails.logger.info "Processing house image: #{house_image.original_filename}"
      Rails.logger.info "Content type: #{house_image.content_type}"
      Rails.logger.info "File size: #{house_image.size} bytes"
      
      # Convert the uploaded image to base64
      image_base64 = Base64.strict_encode64(house_image.read)
      Rails.logger.info "Image successfully converted to base64"
      
      # Simple prompt for testing
      test_prompt = "Describe this image briefly."
      
      Rails.logger.info "Sending test request to OpenAI GPT-4o with vision capabilities"
      
      # Test GPT-4 vision API
      gpt_response = client.chat(
        parameters: {
          model: "gpt-4o",
          messages: [
            {
              role: "user",
              content: [
                { type: "text", text: test_prompt },
                {
                  type: "image_url",
                  image_url: {
                    url: "data:#{house_image.content_type};base64,#{image_base64}"
                  }
                }
              ]
            }
          ],
          max_tokens: 300
        }
      )
      
      # Extract GPT-4's description
      analysis = gpt_response.dig("choices", 0, "message", "content")
      
      render json: {
        status: "success",
        message: "Vision API test successful",
        analysis: analysis,
        api_info: {
          model: "gpt-4o",
          api_key_present: api_key.present?,
          organization_id_present: org_id.present?
        }
      }
      
    rescue OpenAI::Error => e
      Rails.logger.error "OpenAI API Error in debug: #{e.message}"
      Rails.logger.error "Error type: #{e.class}"
      Rails.logger.error "Error backtrace: #{e.backtrace.join("\n")}" if e.backtrace
      
      render json: {
        status: "error",
        message: "OpenAI API Error: #{e.message}",
        error_type: e.class.to_s,
        api_info: {
          model: "gpt-4o",
          api_key_present: api_key.present?,
          organization_id_present: org_id.present?
        }
      }, status: :unprocessable_entity
      
    rescue StandardError => e
      Rails.logger.error "Error in debug: #{e.message}"
      Rails.logger.error "Error type: #{e.class}"
      Rails.logger.error e.backtrace.join("\n") if e.backtrace
      
      render json: {
        status: "error",
        message: e.message,
        error_type: e.class.to_s,
        api_info: {
          model: "gpt-4o",
          api_key_present: api_key.present?,
          organization_id_present: org_id.present?
        }
      }, status: :unprocessable_entity
    end
  end
end
