class Message < ApplicationRecord
  belongs_to :user
  belongs_to :conversation, optional: true
  has_one_attached :image, dependent: :purge_later

  validates :content, presence: true
  validates :role, presence: true, inclusion: { in: %w[user assistant] }

  scope :ai_chat, -> { where(conversation_id: nil) }
  scope :user_chat, -> { where.not(conversation_id: nil) }

  def ai_message?
    role == 'assistant'
  end

  def user_message?
    role == 'user'
  end
end
