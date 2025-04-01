json.id post.id
json.title post.title
json.body post.body
json.created_at post.created_at
json.updated_at post.updated_at
json.likes_count post.likes_count
json.repost_count post.repost_count
json.user do
  json.id post.user.id
  json.email post.user.email
  json.name post.user.name
  json.avatar_url post.user.avatar.attached? ? url_for(post.user.avatar) : nil
end 
