class Post < ApplicationRecord
  after_create_commit { broadcast_prepend_later_to 'posts' }
  after_update_commit { broadcast_replace_later_to 'posts' }
  after_destroy_commit { broadcast_remove_to 'posts' }

  validates :body, length: { minimum: 1, maximum: 280 }
  belongs_to :user
  scope :by_user, ->(user) { where(user_id: user.id) }

  scope :search, ->(query) { where("body LIKE ?", "%#{query}%") }
end
