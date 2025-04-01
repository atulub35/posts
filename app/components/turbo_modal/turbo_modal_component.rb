# frozen_string_literal: true

class TurboModal::TurboModalComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer
  def initialize(title: nil, cancel_text: "Cancel", destrictive: false, modal_size: "modal-md")
    @title = title
    @cancel_text  = cancel_text
    @destrictive = destrictive
    @modal_size = modal_size
  end
end
