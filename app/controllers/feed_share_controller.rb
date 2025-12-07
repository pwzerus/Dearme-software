class FeedShareController < ApplicationController
  include PostFilteringControllerConcern

  FEED_SHARE_TTL = 1.hour

  # End point to show the feed share link as well
  # as manage users who currently have access to the
  # logged in user's feed.
  def index
    token = current_user.feed_share_token.token
    @share_user_feed_url = share_user_feed_url(token: token)

    # Which UserViewUser records are active where current user
    # is the viewee
    @viewers_view_current_user =
      UserViewUser.active.where(viewee: current_user)

    puts @viewers_view_current_user
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

    # Find an active user view user where the current user
    # views another user.
    uvu = UserViewUser.find_active(
            viewer: current_user,
            viewee: user
            )
    if uvu.nil?
      raise "You cannot access that user's feed, either it was" \
            "never shared or the share has expired !"
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

  # Revoke access of the current user's feed shared with the
  # user :user_id
  #
  # DELETE /revoke_shared_access/:user_id
  def revoke_shared_feed_access
    user = User.find(params[:user_id])

    # Find an active user view user where current user is viewed
    # by another user
    uvu = UserViewUser.find_active(
            viewee: current_user,
            viewer: user
            )
    if uvu.nil?
      raise "User doesn't have access to your shared feed"
    end

    # Destroying the record so that our system no longer considers
    # that user to have access to shared feed.
    uvu.destroy!

    Rails.logger.info
      "User #{current_user.id} revoked feed access of #{user.id}"
    flash[:notice] = "Revoked feed access successfully !"
    redirect_to feed_share_manager_path
  rescue => e
    msg = "Failure while revoking shared feed access: #{e.message}"
    Rails.logger.error msg
    flash[:error] = msg

    redirect_to dashboard_path
  end
end
