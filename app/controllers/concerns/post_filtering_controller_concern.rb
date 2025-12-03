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
      user.posts
    end
  end
end
