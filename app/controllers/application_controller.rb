class ApplicationController < ActionController::Base
  # Gate everything by default; controllers like LoginController can skip it
  before_action :require_login

  helper_method :current_user

  def current_user
    # populate from session set in LoginController#omniauth_callback
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_login
    return if current_user

    flash[:alert] = "Login required!"
    redirect_to login_path
  end
end
