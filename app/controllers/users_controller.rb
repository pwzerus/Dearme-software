# app/controllers/users_controller.rb
class UsersController < ApplicationController
  # ApplicationController already runs require_login before each action

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to dashboard_path, notice: "Profile updated successfully."
    else
      # Re render the form with validation errors
      render :edit, status: :unprocessable_entity
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
end
