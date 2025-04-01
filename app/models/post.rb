class Post < ApplicationRecord
  # after_create_commit { broadcast_prepend_later_to 'posts', locals: { user_id: user_id } }
  # after_update_commit { broadcast_replace_later_to 'posts', locals: { user_id: user_id } }
  # after_destroy_commit { broadcast_remove_to 'posts' }
  validates :body, length: { minimum: 1, maximum: 1880 }
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  belongs_to :user 
  scope :by_user, ->(user) { where(user_id: user.id) }

  scope :search, ->(query) { joins(:rich_text_body).where("LOWER(action_text_rich_texts.body) LIKE LOWER(?)", "%#{query}%") }

  has_rich_text :body
end
