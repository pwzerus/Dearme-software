class PostsController < ApplicationController
  def create
    @post = Post.new(creator: current_user,
                     title: default_post_title)
    if @post.save
      # Saved successfully
      Rails.logger.info "Post created successfully with id #{@post.id}"

      flash[:notice] = "Post created successfully"
      redirect_to post_path(@post)
    else
      Rails.logger.error "Failed to create a post #{post_error_str(@post)}"

      flash[:notice] = "Failed to create a post #{post_error_str(@post)}"
      redirect_to dashboard_path
    end
  end

  def show
    @post = Post.find(params[:id])
  rescue => e
    Rails.logger.error "Failed to display post, reason: #{e.message}"
    flash[:error] = "Failed to display post, reason: #{e.message}"
    redirect_to dashboard_path
  end

  private
    # Get the error string explaining why a post related
    # activity failed on the p object
    def post_error_str(p)
      p.errors.full_messages.join(", ")
    end

    # Default title to use for posts
    def default_post_title
      "Post #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    end
end
