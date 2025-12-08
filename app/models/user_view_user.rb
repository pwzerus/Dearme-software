class UserViewUser < ApplicationRecord
  # The one viewing
  belongs_to :viewer, class_name: "User"

  # The one being viewed
  belongs_to :viewee, class_name: "User"

  # No two records should have same viewer, viewee pair
  validates :viewer_id, uniqueness: { scope: :viewee_id }

  # The user should not be able to view themselves (loop)
  validate :user_cannot_view_self

  def active?
    expires_at.nil? || expires_at >= Time.current
  end

  def expired?
    !active?
  end

  # Return all active records (not expired)
  def self.active
    # nil - no expiry date
    # or expires_at >= Current time
    where(expires_at: nil).or(
            where(expires_at: Time.current..)
            )
  end

  # Find an active user view user record with the given
  # viewer and viewee
  def self.find_active(viewer:, viewee:)
    uvu = self.find_by(viewer: viewer, viewee: viewee)
    return nil if uvu.nil?

    uvu.active? ? uvu : nil
  end

  def self.can_user_view_another?(user, another_user)
    uvu = self.find_active(viewer: user, viewee: another_user)
    uvu.present?
  end

  private

  def user_cannot_view_self
    if viewer_id == viewee_id
      errors.add(:base,
                 "Users shouldn't be able to view themselves, self loop" \
                 "doesn't make sense, since this viewing is meant for " \
                 "sharing")
    end
  end
end
