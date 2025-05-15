module Notification
  class NotificationComponent < ViewComponent::Base
    def initialize(message:, flash_type:)
      @message = message
      @flash_type = flash_type
    end

    def alert_class
      @flash_type == 'notice' ? 'success' : 'danger'
    end
  end
end 