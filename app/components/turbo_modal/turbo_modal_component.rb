# frozen_string_literal: true

class TurboModal::TurboModalComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer
  def initialize(title: nil, cancel_text: "Cancel", destrictive: false)
    @title = title
    @cancel_text  = cancel_text
    @destrictive = destrictive
  end
end
