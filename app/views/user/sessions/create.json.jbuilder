json.status do
  json.code 200
  json.message 'Logged in successfully.'
end

json.data do
  json.user do
    json.id @resource.id
    json.email @resource.email
  end
  json.redirect_path @redirect_path
end 