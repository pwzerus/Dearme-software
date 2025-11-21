class PostsController < ApplicationController
  # Set @post based on params[:id]
  before_action :set_post!, only: [ :show, :edit, :update, :destroy ]

  # Validate that the editor of the post is the
  # creator and no one else
  before_action :validate_post_creator!, only: [ :edit, :update, :destroy ]

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
  end

  # GET /posts/:id/edit to show the edit page for the post
  def edit
  end

  # PATCH/PUT /posts/:id to update the post
  def update
    # Not accepting NEW media files as part of the post_update_params
    # under params[:post][:media_files] (i.e. I did NOT utilize the accepts
    # nested attributes concept for NEW media files) because the front end
    # needs to be able to:
    #
    # - select multiple media files to add
    # - do it without Javascript support
    #
    # Now, doing that as a part of post_update_params means that we have
    # to create some blank @post.media_files in the edit controllers with
    # no files attached and allow user adding only those many files as we
    # have created blank media files for.
    #
    # But I didn't want that limitation of limiting the uploads to the number
    # of blanks, so:
    # - the new media files to add are accepted under params[:added_files]
    #   (allows user to upload as many new media files as they want without
    #    limits)
    #
    # - the existing media files to edit (e.g.) remove are accepted under post
    #   param i.e. under params[:post][:media_files] (utilizes the accepts
    #   nested attributes concept of rails)

    if params[:added_files].present?
      params[:added_files].each do |uploaded_file|
        @post.media_files.create!(
                file: uploaded_file,
                file_type:
                MediaFile.type_from_content_type(uploaded_file.content_type)
                )
      end
    end

    @post.update!(post_update_params)
    Rails.logger.info "Post #{@post.id} updated successfully"
    flash[:notice] = "Post updated successfully"

    redirect_to post_path(@post)
  rescue => e
    Rails.logger.info "Failed to update post: #{e.message}"
    flash[:error] = "Failed to update the post: #{e.message}"
    redirect_to dashboard_path
  end

  # DELETE /posts/:id to delete a post
  def destroy
    @post.destroy!
    Rails.logger.info "Post destroyed successfully"
    flash[:notice] = "Post destroyed successfully"

    redirect_to dashboard_path
  rescue => e
    Rails.logger.info "Failed to destroy post: #{e.message}"
    flash[:error] = "Failed to destroy the post: #{e.message}"
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

    def set_post!
      @post = Post.find(params[:id])
    rescue => e
      Rails.logger.error "Failed to find post, reason: #{e.message}"
      flash[:error] = "Failed to find post, reason: #{e.message}"
      redirect_to dashboard_path
    end

    def validate_post_creator!
      unless current_user == @post.creator
        flash[:alert] = "Not the post creator, operation now allowed !"
        Rails.logger.info "Denying non post creator user #{current_user.id}"
        redirect_to dashboard_path
      end
    end

    # Filter out the parameters needed to update a post
    def post_update_params
      params.require(:post).permit(
              :title,
              :description,
              :archived,
              media_files_attributes: [:id, :_destroy]
              )
    end
end
