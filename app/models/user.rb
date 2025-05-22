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
  has_many :generated_images, dependent: :destroy
  validate :correct_avatar_mime_type
  
  attr_accessor :remove_avatar

  # Constants
  ONLINE_THRESHOLD = 5.minutes
  AWAY_THRESHOLD = 2.minutes

  after_save :handle_remove_avatar

  # Direct URL for avatar without image processing
  def avatar_url
    return nil unless avatar.attached?
    Rails.application.routes.url_helpers.url_for(avatar)
  end

  # Track user's online presence
  def update_online_status
    begin
      update(online_status: true, last_seen_at: Time.current)
    rescue => e
      Rails.logger.error("Failed to update online status: #{e.message}")
      # If update fails, at least try to update the attributes without validation
      self.online_status = true
      self.last_seen_at = Time.current
      self.save(validate: false) rescue nil
    end
  end

  # Mark user as offline
  def update_offline_status
    begin
      update(online_status: false, last_seen_at: Time.current)
    rescue => e
      Rails.logger.error("Failed to update offline status: #{e.message}")
      # If update fails, at least try to update the attribute without validation
      self.online_status = false
      self.last_seen_at = Time.current
      self.save(validate: false) rescue nil
    end
  end

  # Check if user is online
  def online?
    begin
      return false unless last_seen_at
      online_status && last_seen_at > ONLINE_THRESHOLD.ago
    rescue => e
      Rails.logger.error("Error checking online status: #{e.message}")
      false
    end
  end
  
  # Check if user is away (not active but tab still open)
  def away?
    begin
      return false unless last_seen_at
      !online_status && last_seen_at > AWAY_THRESHOLD.ago
    rescue => e
      Rails.logger.error("Error checking away status: #{e.message}")
      false
    end
  end

  # Get user status
  def status
    if online?
      'online'
    elsif away?
      'away'
    else
      'offline'
    end
  end

  private 
  
  def correct_avatar_mime_type
    if avatar.attached? && !avatar.content_type.in?(%w(image/png image/jpg image/jpeg))
      errors.add(:avatar, 'must be a PNG or JPG image')
    end
  end
  
  def handle_remove_avatar
    avatar.purge if remove_avatar == '1' && avatar.attached?
  end
end
