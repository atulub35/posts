# Add this at the top to debug
Rails.logger.debug "JWT Token: #{request.env['warden-jwt_auth.token']}"

json.status do
  json.code 200
  json.message 'Logged in successfully.'
end

json.data do
  json.user do
    json.id @resource.id
    json.email @resource.email
  end
  # Try both ways to access the token
  json.token request.env['warden-jwt_auth.token']
  json.auth_token response.headers['Authorization']&.split(' ')&.last
  json.redirect_path @redirect_path
end 