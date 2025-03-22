json.status do
  json.code 200
  json.message 'Logged out successfully.'
end

json.data do
  json.redirect_path @redirect_path
end 