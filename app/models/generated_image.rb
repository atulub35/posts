class GeneratedImage < ApplicationRecord
  belongs_to :user
  has_one_attached :image, dependent: :purge_later
  
  validates :prompt, presence: true
  
  # Custom method to get the URL of the image
  def image_url
    if image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(image)
    else
      original_url
    end
  end
end
