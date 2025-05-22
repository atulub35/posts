json.status do
  json.code 200
  json.message "Successfully generated image"
end

json.data do
  if @generated_image&.persisted?
    json.image_url rails_blob_url(@generated_image.image)
    json.id @generated_image.id
    json.prompt @generated_image.prompt
    json.created_at @generated_image.created_at
  else
    json.image_url @image_url
  end
end 