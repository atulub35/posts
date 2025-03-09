# frozen_string_literal: true

class TurboModalComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer
  def initialize(title: nil)
    @title = title
  end
end
