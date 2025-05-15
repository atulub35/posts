json.status do
  json.code 201
  json.message 'Image created successfully.'
end

json.data do
  json.image_url @image_url
end 