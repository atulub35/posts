json.status do
  json.code 200
  json.message "Successfully retrieved images"
end

json.data do
  json.images @generated_images do |image|
    json.id image.id
    json.prompt image.prompt
    json.is_variant image.is_variant
    json.style image.style if image.style.present?
    
    if image.image.attached?
      json.image_url rails_blob_url(image.image)
    else
      json.image_url image.original_url
    end
    
    json.created_at image.created_at
    json.updated_at image.updated_at
  end
end 