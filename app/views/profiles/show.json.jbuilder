json.status do
  json.code 200
  json.message 'Profile retrieved successfully.'
end

json.user do
  json.id @user.id
  json.email @user.email
  json.name @user.name
  json.phone_number @user.phone_number
  json.language @user.language
  json.timezone @user.timezone
  json.avatar_url @user.avatar.attached? ? url_for(@user.avatar) : nil
end