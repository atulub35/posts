class PostsController < ApplicationController
  include Pagy::Backend
  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  respond_to :html, :json, :turbo_stream
  before_action :authenticate_user!
  before_action :find_post, only: %i[destroy edit update show like repost]

  def index
    if params[:query].present?
      @pagy, @posts = pagy(Post.search(params[:query]))
    else
      @pagy, @posts = pagy(Post.all.with_rich_text_body.order(created_at: :desc))
    end
  

    respond_to do |format|
      format.html
      format.json do
        if user_signed_in?
          render 'index'
        else
          render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
        end
      end
    end
    
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.build(post_params)
    respond_to do |format|
      if @post.save
        format.turbo_stream
        broadcast_post(@post)
        format.html { redirect_to posts_path, notice: 'Post was successfully created.' }
        format.json
      else
        flash.now[:alert] = @post.errors.full_messages.first
        format.turbo_stream { render :create, status: 406 }
        format.json { render json: { error: @post.errors.full_messages.first }, status: 406 }
      end
    end
  end

  def edit
    # @post = Post.find(params[:id])
  end

  def update
    if @post.update(post_params)
      flash.now[:notice] = "Post was successfully updated."
      broadcast_post_update(@post)
      respond_to do |format|
        format.turbo_stream
        format.json
        format.html { redirect_to posts_path, notice: 'Post was successfully updated.' }
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
    @post.increment(:likes_count).save
    respond_to do |format|
      if @post.save
        broadcast_post_update(@post)
        format.html { redirect_to posts_path, notice: 'Post was successfully liked.' }
        format.json
      else
        flash.now[:alert] = @post.errors.full_messages.first
        format.turbo_stream { render :create, status: 406 }
        format.json { render json: { error: @post.errors.full_messages.first }, status: 406 }
      end
    end
  end

  def repost
    @post.increment(:repost_count).save
    respond_to do |format|
      if @post.save
        broadcast_post_update(@post)
        format.html { redirect_to posts_path, notice: 'Post was successfully liked.' }
        format.json
      else
        flash.now[:alert] = @post.errors.full_messages.first
        format.turbo_stream { render :create, status: 406 }
        format.json { render json: { error: @post.errors.full_messages.first }, status: 406 }
      end
    end
  end

  def destroy
    if @post.destroy
      flash.now[:notice] = "Post was successfully deleted."
      broadcast_post_delete(@post)
    else
      flash[:error] = "There was an error deleting the post."
    end
    respond_to do |format|
      format.html { redirect_to posts_path }
      format.json { head :ok }
    end
  end

  private

  def broadcast_post(post)
    Turbo::StreamsChannel.broadcast_prepend_later_to(
      "posts",
      target: "posts",
      partial: "posts/post",
      locals: { post: post, editable: current_user.id == post.user.id }
    )
  end

  def broadcast_post_update(post)
    Turbo::StreamsChannel.broadcast_replace_later_to(
      "posts",
      target: post,
      partial: "posts/post",
      locals: { post: post, editable: current_user.id == post.user.id }
    )
  end

  def broadcast_post_delete(post)
    Turbo::StreamsChannel.broadcast_remove_to(
      "posts",
      target: post
    )
  end

  def find_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:body, :rich_text_body, :title)
  end
end