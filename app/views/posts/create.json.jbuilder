json.status do
  json.code 200
  json.message 'Post created successfully.'
end

json.data do
  json.partial! 'posts/post', post: @post
end
