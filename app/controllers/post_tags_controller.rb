class PostTagsController < ApplicationController

  def create
    @post = find_post_for_current_user
    @tag  = find_tag_for_current_user

    @post_tag = PostTag.new(post: @post, tag: @tag)

    if @post_tag.save
      redirect_to post_path(@post), notice: "Tag added to post."
    else
      redirect_to post_path(@post), alert: @post_tag.errors.full_messages.to_sentence
    end
  end

  def destroy
    @post_tag = find_post_tag_for_current_user
    @post     = @post_tag.post

    @post_tag.destroy

    redirect_to post_path(@post), notice: "Tag removed from post."
  end

  private

  def post_tag_params
    params.require(:post_tag).permit(:post_id, :tag_id)
  end

  # Only allow posts owned by the current user (creator)
  def find_post_for_current_user
    Post.where(creator: current_user).find(post_tag_params[:post_id])
  end

  # Only allow tags owned by the current user (creator)
  def find_tag_for_current_user
    Tag.where(creator: current_user).find(post_tag_params[:tag_id])
  end

  def find_post_tag_for_current_user
    PostTag
      .joins(:post, :tag)
      .where(posts: { creator_id: current_user.id },
             tags:  { creator_id: current_user.id })
      .find(params[:id])
  end
end
