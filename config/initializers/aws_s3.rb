# Configure AWS S3 for direct links
if Rails.env.development? || Rails.env.production?
  begin
    require 'aws-sdk-s3'
    
    # Configure AWS S3 client
    Aws.config.update({
      region: ENV['AWS_REGION'],
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    })
    
    # Override Active Storage service URL method to return pre-signed URLs
    Rails.application.config.to_prepare do
      ActiveStorage::Blob.class_eval do
        def service_url(expires_in: ActiveStorage.service_urls_expire_in, disposition: :inline, filename: nil, **options)
          service = service_name.to_sym
          if service == :amazon
            # Use pre-signed URLs for S3 with public-read ACL
            s3_client = Aws::S3::Client.new
            signer = Aws::S3::Presigner.new(client: s3_client)
            
            filename = ActiveStorage::Filename.new(filename || self.filename)
            
            response = signer.presigned_url(
              :get_object, 
              bucket: ENV['AWS_BUCKET'],
              key: key,
              expires_in: expires_in,
              response_content_disposition: content_disposition_with(type: disposition, filename: filename)
            )
            return response
          else
            super
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