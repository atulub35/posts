# Enable direct URLs for AWS S3
Rails.application.config.after_initialize do
  ActiveStorage::Blob.include(ActiveStorage::Blob::Analyzable)
  
  # Add a method to check if a blob is stored on S3
  ActiveStorage::Blob.class_eval do
    def s3?
      service_name.to_s == "amazon"
    end
  end
  
  # Use service_url with public URLs when appropriate
  ActiveStorage::Blob.class_eval do
    def url_for_direct_upload(expires_in: nil)
      if s3?
        service.url_for_direct_upload(key, expires_in: expires_in)
      else
        super
      end
    end
  end
  
  # Ensure variants can use service_url as well
  ActiveStorage::Variant.class_eval do
    def processed_url
      if blob.s3?
        service.url(key, disposition: :inline, filename: filename, content_type: content_type)
      else
        super
      end
    end
  end
end 