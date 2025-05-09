class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
  has_many :posts
  has_many :messages
  has_many :ai_messages, -> { ai_chat }, class_name: 'Message'
  has_many :user_messages, -> { user_chat }, class_name: 'Message'
  has_many :conversation_participants
  has_many :conversations, through: :conversation_participants
  has_one_attached :avatar
  has_many :images, dependent: :destroy
  validate :correct_avatar_mime_type

  def avatar_thumbnail
    return nil unless avatar.attached?
    avatar.variant(resize_to_fill: [48, 48]).processed
  end

  def avatar_small
    return nil unless avatar.attached?
    avatar.variant(resize_to_fill: [32, 32]).processed
  end

  def avatar_mini
    return nil unless avatar.attached?
    avatar.variant(resize_to_fill: [24, 24]).processed
  end

  private 
  
  def correct_avatar_mime_type
    if avatar.attached? && !avatar.content_type.in?(%w(image/png image/jpg image/jpeg))
      errors.add(:avatar, 'must be a PNG or JPG image')
    end
  end
end
