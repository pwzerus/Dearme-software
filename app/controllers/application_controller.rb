class ApplicationController < ActionController::Base
  # Gate everything by default; controllers like LoginController can skip it
  before_action :require_login

  helper_method :current_user

  def current_user
     # populate from session set in LoginController#omniauth_callback
     # Any request that needs a user (like /dashboard) is protected.
     # If there is no logged in user, it sets the flash message "Login required!" and redirects to login_path
     @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    return if current_user

    # Before redirecting to login page, store the url which user
    # wanted to access, after login's complete we would redirect him
    # back there (as the user's now logged in)
    session[:original_url_to_visit] = request.fullpath

    flash[:alert] = "Login required!"
    redirect_to login_path
  end
end
