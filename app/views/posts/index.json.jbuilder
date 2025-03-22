json.data do
  json.posts do
    json.array! @posts do |post|
      json.id post.id
      json.created_at post.created_at
      json.body post.body
      json.updated_at post.updated_at
      json.likes_count post.likes_count
      json.repost_count post.repost_count
      
      json.user do
        json.id post.user.id
        json.email post.user.email
        json.name post.user.name
        json.avatar_url post.user.avatar.attached? ? url_for(post.user.avatar) : nil
      end
    end
  end

  json.pagination do
    json.current_page @pagy.page
    json.total_pages @pagy.pages
    json.total_count @pagy.count
    json.next_page @pagy.next
    json.prev_page @pagy.prev
  end
end