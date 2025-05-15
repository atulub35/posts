json.status do
  json.code 200
  json.message 'Images retrieved successfully.'
end

json.data do
  json.images @generated_images do |img|
    json.id img[:id]
    json.description img[:prompt]
    json.image_url img[:url]
    json.created_at img[:created_at]
  end
end 