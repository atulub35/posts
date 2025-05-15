# Configure AWS S3 for private access with pre-signed URLs
if Rails.env.development? || Rails.env.production?
  begin
    require 'aws-sdk-s3'
    
    # Configure AWS S3 client
    Aws.config.update({
      region: ENV['AWS_REGION'],
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    })
    
    # Extend Active Storage for pre-signed URLs
    Rails.application.config.to_prepare do
      ActiveStorage::Blob.class_eval do
        # Create a pre-signed URL for this blob that expires in 30 minutes
        def presigned_url(expires_in: 30.minutes)
          if service_name.to_sym == :amazon
            s3_client = Aws::S3::Client.new
            signer = Aws::S3::Presigner.new(client: s3_client)
            
            # Generate a pre-signed URL
            response = signer.presigned_url(
              :get_object, 
              bucket: ENV['AWS_BUCKET'],
              key: key,
              expires_in: expires_in.to_i
            )
            return response
          else
            # For non-S3 services, fall back to normal URL
            service.url(key, expires_in: expires_in, disposition: :inline)
          end
        end
        
        # Make variants also use pre-signed URLs
        def variant_presigned_url(options, expires_in: 30.minutes)
          # Process the variant first
          processed_variant = self.variant(options).processed
          
          if service_name.to_sym == :amazon
            s3_client = Aws::S3::Client.new
            signer = Aws::S3::Presigner.new(client: s3_client)
            
            # Use original blob's filename and content_type if not explicitly provided
            variant_filename = self.filename.to_s.sub(/\.\w+$/) { |ext| "-variant#{ext}" }
            
            # Generate a pre-signed URL for the variant
            signer.presigned_url(
              :get_object, 
              bucket: ENV['AWS_BUCKET'],
              key: processed_variant.key,
              expires_in: expires_in.to_i
            )
          else
            # For non-S3 services, fall back to normal URL
            processed_variant.url
          end
        end
      end
    end
  rescue LoadError => e
    # AWS SDK not available
    Rails.logger.warn "AWS S3 SDK not available: #{e.message}"
  rescue StandardError => e
    # Configuration error
    Rails.logger.error "Error configuring AWS S3: #{e.message}"
  end
end 