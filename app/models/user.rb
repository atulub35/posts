class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist
  has_many :posts
  has_many :messages
  has_one_attached :avatar
  validate :correct_avatar_mime_type

  # Validation (Optional)
  # validates :avatar, content_type: [:png, :jpg, :jpeg],
  #                    size: { less_than: 5.megabytes , message: 'is not given between size' }
  private 
  
  def correct_avatar_mime_type
    if avatar.attached? && !avatar.content_type.in?(%w(image/png image/jpg image/jpeg))
      errors.add(:avatar, 'must be a PNG or JPG image')
    end
  end
end
