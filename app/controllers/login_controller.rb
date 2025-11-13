# app/controllers/login_controller.rb
class LoginController < ApplicationController
  # Don't need login to reach the login page or callback
  skip_before_action :require_login, only: [:new, :omniauth_callback, :failure], raise: false

  # GET /login
  def new
  end

  # GET /auth/:provider/callback
  def omniauth_callback
    auth = request.env["omniauth.auth"]

    user = User.find_or_initialize_by(email: auth.info.email)
    if user.new_record?
      user.first_name = auth.info.first_name
      user.last_name  = auth.info.last_name
    end
    user.save!

    session[:user_id] = user.id
    redirect_to dashboard_path
  rescue => e
    Rails.logger.error "Authentication failed: #{e.message}"
    flash[:alert] = "Authentication failed! #{e.message}"
    redirect_to login_path
  end

  # GET /auth/failure
  def failure
    flash[:alert] = "Authentication failed: #{params[:message]}"
    redirect_to login_path
  end

  # DELETE /logout
  def destroy
    session.delete(:user_id)
    flash[:notice] = "Logged out successfully!"
    redirect_to root_path
  end
end
