class FeedShareController < ApplicationController
  include PostFilteringControllerConcern

  FEED_SHARE_TTL = 1.hour

  # End point to show the feed share link as well
  # as manage users who currently have access to the
  # logged in user's feed.
  def index
    token = current_user.feed_share_token.token
    @share_user_feed_url = share_user_feed_url(token: token)
  rescue => e
    msg = "Feed share failure: #{e.message}"
    Rails.logger.error msg
    flash[:error] = msg

    redirect_to dashboard_path
  end

  # End point that gets hit when a user vists the SHARE FEED LINK
  # of another user (we want to provide access to the former user
  # of the latter's feed)
  def share_user_feed
    token = params.require(:token)

    details = TokenHandlerService.retrieve_hash_from_token(token)
    if details[:user_id].nil? || details[:expires_at].nil?
      raise "Invalid feed share information received: #{details}"
    end

    user = User.find(details[:user_id])
    token_expires_at = Time.parse(details[:expires_at])

    if user == current_user
      flash[:notice] = "Cannot share feed with self!"
      redirect_to dashboard_path and return
    end

    if Time.current > token_expires_at
      raise "Received expired shared feed token, " \
            "expired at: #{token_expires_at}"
    end

    # create or update the existing user view user
    uvu = UserViewUser.find_or_initialize_by(
            viewer: current_user,
            viewee: user
            )

    uvu.expires_at = Time.current + FEED_SHARE_TTL
    uvu.save!

    # Redirect to the view that shows a user all the feeds
    # shared with them
    Rails.logger.info
      "User #{user.id} feed shared with #{current_user.id} successfully"
    flash[:notice] = "Shared feed access successful"
    redirect_to shared_user_feeds_path
  rescue => e
    msg = "Failure while trying to share user feed: #{e.message}"
    Rails.logger.error msg
    flash[:error] = msg

    redirect_to dashboard_path
  end

  # List all user feeds that are shared with the logged in
  # user (and which he can still view i.e. feed share not
  # expired for those feeds)
  def shared_user_feeds
    # Get user view user records where the curret user is
    # the viewer and the share access hasn't expired yet
    #
    # Order by most recent shared feed to least recent
    @current_user_view_users =
      UserViewUser.where(viewer: current_user)
                  .where(expires_at: Time.current..)
                  .order(updated_at: :desc)
                  .includes(:viewee)
  end

  # GET /shared_user_feed/:user_id
  # Show the user feed of :user_id to the current user
  def shared_user_feed
    user = User.find(params[:user_id])

    uvu = UserViewUser.find_by(viewer: current_user, viewee: user)
    if uvu.nil?
      raise "User's feed hasn't been shared with you, can't access it"
    end

    if uvu.expired?
      raise "User feed shared with you has expired"
    end

    # Render the posts index page showing posts of the
    # user to current user
    @user = user
    @user_tags = @user.tags.order(:title)
    @show_status_filter = false
    @posts = filter_posts_of(user)

    # The filters of the page should send the filter requests to
    # this end point (current one)
    @filter_url = shared_user_feed_path(user)

    render "posts/index"
  rescue => e
    msg = "Failure while displaying user feed: #{e.message}"
    Rails.logger.error msg
    flash[:error] = msg

    redirect_to dashboard_path
  end
end
