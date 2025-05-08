class SearchController < ApplicationController
  def index
    @query = params[:q]
    
    if @query.present?
      @posts = Post.where("title ILIKE ? OR content ILIKE ?", "%#{@query}%", "%#{@query}%")
      @users = User.where("username ILIKE ? OR email ILIKE ?", "%#{@query}%", "%#{@query}%")
      # @images = Image.where("title ILIKE ? OR description ILIKE ?", "%#{@query}%", "%#{@query}%")
    else
      @posts = []
      @users = []
      @images = []
    end

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end
end 