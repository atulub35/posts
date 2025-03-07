class PostsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :set_post, only: %i[destroy edit update show]

  def index
    if params[:query].present?
      @pagy, @posts = pagy(Post.search(params[:query]))
    else
      @pagy, @posts = pagy(Post.all.order(created_at: :desc))
    end
    # @post = Post.new
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.build(post_params)
    # @post = Post.new(post_params)
    # respond_to do |format|
    #   if @post.save
    #     # format.turbo_stream
    #     format.html { redirect_to profiles_show_path, notice: 'Post was successfully created.' }
    #   else
    #     # format.turbo_stream { render turbo_stream: turbo_stream.replace(@post, partial: 'posts/form', locals: { post: @post }) } ## New for this article
    #     flash.now[:alert] = @post.errors.full_messages.first
    #     format.turbo_stream { render :create, status: 406 }
    #   end
    # end
    redirect_to profiles_show_path
  end

  def edit
    # @post = Post.find(params[:id])
  end

  def update
    if @post.update(post_params)
      flash.now[:notice] = "Post was successfully updated."
      respond_to do |format|
        format.html { redirect_to profiles_show_path, notice: 'Post was successfully updated.' }
      end
    else
      respond_to do |format|
        flash.now[:notice] = @post.errors.full_messages.first
        format.html { render :edit }
      end
    end
  end

  def show
  end

  def like
    Post.find_by(id: params[:id]).increment(:likes_count).save ## New for this article
    redirect_to posts_path
  end

  def repost
    Post.find_by(id: params[:id]).increment(:repost_count).save ## New for this article
    redirect_to posts_path
  end

  def destroy
    if @post.destroy
      flash.now[:notice] = "Post was successfully deleted."
    else
      flash[:error] = "There was an error deleting the post."
    end
    # redirect_to posts_path
    respond_to do |format|
      format.html { redirect_to posts_path }
    end
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:body)
  end
end