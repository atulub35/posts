module Api
  class ImagesController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token, if: -> { request.format.json? }
    respond_to :json

    def index
      @generated_images = current_user.generated_images.order(created_at: :desc)
      render json: {
        status: { code: 200, message: "Successfully retrieved images" },
        data: {
          images: @generated_images.map do |image|
            {
              id: image.id,
              prompt: image.prompt,
              is_variant: image.is_variant,
              style: image.style,
              image_url: image.image.attached? ? url_for(image.image) : image.original_url,
              created_at: image.created_at,
              updated_at: image.updated_at
            }
          end
        }
      }
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
          
          # Save the image to S3 if user is authenticated
          if current_user.present?
            # Create a new GeneratedImage record
            @generated_image = current_user.generated_images.new(
              prompt: prompt,
              original_url: @image_url
            )
            
            # Download the image from OpenAI
            image_response = URI.open(@image_url)
            
            # Attach the image to our GeneratedImage record
            @generated_image.image.attach(
              io: image_response,
              filename: "dalle-#{Time.current.to_i}.png",
              content_type: 'image/png'
            )
            
            if @generated_image.save
              # Update the image_url to use our S3 URL
              @image_url = url_for(@generated_image.image)
              Rails.logger.info "Image saved to S3: #{@image_url}"
            else
              Rails.logger.error "Failed to save GeneratedImage record: #{@generated_image.errors.full_messages.join(', ')}"
            end
          end

          render json: {
            status: { code: 200, message: "Successfully generated image" },
            data: {
              image_url: @image_url,
              id: @generated_image&.id,
              prompt: @generated_image&.prompt,
              created_at: @generated_image&.created_at
            }
          }
        else
          Rails.logger.error "Invalid response from OpenAI: #{response.inspect}"
          raise StandardError, "Invalid response from OpenAI"
        end

      rescue OpenAI::Error => e
        Rails.logger.error "OpenAI API Error: #{e.message}"
        render json: { status: { code: 422, message: "OpenAI API Error: #{e.message}" }}, status: :unprocessable_entity
      rescue StandardError => e
        Rails.logger.error "Error processing image: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { status: { code: 422, message: e.message }}, status: :unprocessable_entity
      end
    end

    def destroy
      @generated_image = GeneratedImage.find_by(id: params[:id])
      
      if @generated_image && @generated_image.user_id == current_user.id
        # Delete the image attachment and record
        @generated_image.image.purge if @generated_image.image.attached?
        @generated_image.destroy
        
        render json: { status: { code: 200, message: "Image was successfully deleted." }}
      else
        render json: { status: { code: 403, message: "Unable to delete image." }}, status: :forbidden
      end
    end
  end
end 