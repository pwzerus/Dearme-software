# app/controllers/users_controller.rb
class UsersController < ApplicationController
  # ApplicationController already runs require_login before each action

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    success = @user.update(user_params)
    success &&= handle_profile_picture(@user)

    if success
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

    # Default: nothing to do, nothing failed
    return true unless remove_flag || new_file.present?

    # Remove existing picture if requested
    if remove_flag
      user.profile_picture&.destroy
      Rails.logger.info("Removed profile picture for user #{user.id}")
    end

    # If there is no new file, we are done
    return true unless new_file.present?

    # Replace with new picture
    user.profile_picture&.destroy

    media = MediaFile.new(
      parent:      user,
      file_type:   MediaFile::Type::IMAGE,
      description: "Profile picture"
    )
    media.file.attach(new_file)

    if media.save
      Rails.logger.info("Uploaded new profile picture for user #{user.id}")
      true
    else
      Rails.logger.error(
        "Failed to save profile picture for user #{user.id}. " \
        "Errors: #{media.errors.full_messages.join(', ')}"
      )
      user.errors.add(:base, "Could not update profile picture.")
      false
    end
  end
end
