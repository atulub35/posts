module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token, if: :json_request?
    before_action :authenticate_user!

    private

    def json_request?
      request.format.json?
    end
  end
end 