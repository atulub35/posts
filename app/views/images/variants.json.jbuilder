json.status do
  json.code 200
  json.message "Success"
end

json.data do
  json.variant_image_url @image_url
  json.original_image_data @original_image_data
  json.analysis @analysis
end 