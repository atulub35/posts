class Avatar::AvatarComponent < ViewComponent::Base
  attr_reader :user, :size, :show_status, :class_names

  def initialize(user:, size: 48, show_status: false, class_names: "")
    @user = user
    @size = size
    @show_status = show_status
    @class_names = class_names
  end

  def avatar_style
    "width: #{size}px; height: #{size}px;"
  end

  def font_size
    "#{size / 2.5}px"
  end

  def initials
    if user&.name.present?
      user.name.first.upcase
    elsif user&.email.present?
      user.email.first.upcase
    else
      "?"
    end
  end

  def status_class
    return unless show_status
    
    case user&.status
    when "online"
      "bg-success"
    when "away"
      "bg-warning"
    else
      "bg-secondary"
    end
  end

  def has_avatar?
    user&.avatar&.attached?
  end
end 