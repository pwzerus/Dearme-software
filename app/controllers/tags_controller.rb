class TagsController < ApplicationController
  before_action :set_tag, only: [ :update, :destroy ]

  def index
    @tags = current_user.tags.order(:title)
    @tag  = current_user.tags.new   # for the create form
  end

  def create
    @tag = current_user.tags.new(tag_params)

    if @tag.save
      redirect_to tags_path, notice: "Tag was successfully created."
    else
      # Re-render index with errors and existing tags
      @tags = current_user.tags.order(:title)
      render :index, status: :unprocessable_content
    end
  end

  def update
    if @tag.update(tag_params)
      redirect_to tags_path, notice: "Tag was successfully updated."
    else
      @tags = current_user.tags.order(:title)
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_path, notice: "Tag was successfully deleted."
  end

  private

  def set_tag
    @tag = current_user.tags.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:title)
  end
end
