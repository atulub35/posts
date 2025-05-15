class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:update_status]
  skip_before_action :verify_authenticity_token, only: [:update_status]
  
  # GET /users/:id/status
  def status
    begin
      user = User.find(params[:id])
      
      respond_to do |format|
        format.json do
          render json: {
            online: user.online?,
            last_seen_at: user.last_seen_at,
            last_seen_ago: user.last_seen_at ? view_context.time_ago_in_words(user.last_seen_at) : nil
          }
        end
        format.turbo_stream do
          render json: {
            online: user.online?,
            last_seen_at: user.last_seen_at,
            last_seen_ago: user.last_seen_at ? view_context.time_ago_in_words(user.last_seen_at) : nil
          }
        end
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    rescue => e
      Rails.logger.error("Error checking user status: #{e.message}")
      render json: { error: 'An error occurred' }, status: :internal_server_error
    end
  end
  
  # POST /users/update_status
  def update_status
    begin
      if current_user
        current_user.update_online_status
        
        respond_to do |format|
          format.json { head :ok }
          format.turbo_stream { head :ok }
          format.html { head :ok }
        end
      else
        head :unauthorized
      end
    rescue => e
      Rails.logger.error("Error updating user status: #{e.message}")
      head :internal_server_error
    end
  end
end 