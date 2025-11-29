# app/controllers/users_controller.rb
class UsersController < ApplicationController
  # ApplicationController already runs require_login before each action

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      handle_profile_picture(@user)
      redirect_to dashboard_path, notice: "Profile updated successfully."
    else
      # Re render the form with validation errors
      flash.now[:alert] ||= "Could not update profile picture."
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    user = current_user

    # Clear the session first
    reset_session

    # Remove the user and associated records
    user.destroy!

    redirect_to login_path, notice: "Your account has been deleted."
  end

  private

  def user_params
    # Add any other editable columns as needed
    params.require(:user).permit(
      :first_name,
      :last_name
    )
  end

  def handle_profile_picture(user)
    remove_flag = params[:remove_profile_picture] == "1"
    new_file = params[:profile_picture_file]

    # Remove existing picture
    if remove_flag
      user.profile_picture&.destroy
      Rails.logger.info("Removed profile picture for user #{user.id}")
    end

    # Replace with new picture
    if new_file.present?
      user.profile_picture&.destroy

      media = MediaFile.new(
        parent: user,
        file_type: MediaFile::Type::IMAGE,
        description: "Profile picture"
      )
      media.file.attach(new_file)

      begin
        media.save!
        Rails.logger.info("Uploaded new profile picture for user #{user.id}")
        true
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Failed to save profile picture. Error: #{e.message}")
        false
      end
    end
  end
end
