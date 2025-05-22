class AvatarComponentPreview < ViewComponent::Preview
  def default
    render Avatar::AvatarComponent.new(user: User.first)
  end

  def with_different_sizes
    render_with_template(
      template: "avatar_component_preview/with_different_sizes",
      locals: { user: User.first }
    )
  end

  def with_status
    user = User.first
    render Avatar::AvatarComponent.new(
      user: user,
      size: 60,
      show_status: true
    )
  end
end 