module PostFilteringControllerConcern
  extend ActiveSupport::Concern

  # Methods inside this block would become instance methods of
  # the class who includes this concern
  included do
    # Filters posts for user based on various filters
    # (present in request parameters) and returns the
    # array of posts to showcase
    #
    # TODO: Amesh would add his post filtering logic here
    # later and because this is a concern meant to be included in
    # controllers (based on design), it can use params global
    # variable as one would normally in a controller.
    def filter_posts_of(user)
      posts = user.posts.includes(:tags)

      # Status filter: default to posted (non-archived) unless archived explicitly requested
      posts = if params[:status].to_s == "archived"
                posts.where(archived: true)
      else
                posts.where(archived: false)
      end

      tag_ids = selected_tag_ids
      if tag_ids.any?
        posts = posts.joins(:tags)
                     .where(tags: { id: tag_ids })
                     .distinct
      end

      if (start_date = parsed_date(params[:start_date]))
        posts = posts.where("posts.created_at >= ?", start_date.beginning_of_day)
      end

      if (end_date = parsed_date(params[:end_date]))
        posts = posts.where("posts.created_at <= ?", end_date.end_of_day)
      end

      posts.order(created_at: :desc)
    end

    private

    def selected_tag_ids
      Array(params[:tags]).reject(&:blank?).map(&:to_i)
    end

    def parsed_date(date_str)
      return nil if date_str.blank?
      Date.iso8601(date_str)
    rescue ArgumentError
      nil
    end
  end
end
