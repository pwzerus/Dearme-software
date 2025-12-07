require "rails_helper"

RSpec.describe PostFilteringControllerConcern, type: :controller do
  controller(ApplicationController) do
    include PostFilteringControllerConcern
    def index; head :ok; end
  end

  let(:user) { User.create!(email: "owner@example.com", first_name: "Owner", last_name: "User") }
  let(:other_user) { User.create!(email: "other@example.com", first_name: "Other", last_name: "User") }

  let!(:tag_a) { user.tags.create!(title: "Travel") }
  let!(:tag_b) { user.tags.create!(title: "Work") }
  let!(:other_tag) { other_user.tags.create!(title: "OtherTag") }

  def build_post(title:, created_at:, archived: false, tags: [])
    post = Post.create!(creator: user, title: title, archived: archived)
    post.update_column(:created_at, created_at)
    post.tags << tags if tags.present?
    post
  end

  def filter_with(params_hash)
    allow(controller).to receive(:params).and_return(ActionController::Parameters.new(params_hash))
    controller.filter_posts_of(user)
  end

  describe "#filter_posts_of" do
    it "defaults to posted (non-archived) and orders newest first when no status provided" do
      older = build_post(title: "Old", created_at: Time.zone.parse("2024-05-01"))
      newer = build_post(title: "New", created_at: Time.zone.parse("2024-05-02"))
      archived = build_post(title: "Archived", created_at: Time.zone.parse("2024-05-03"), archived: true)

      result = filter_with({})

      expect(result).to eq([ newer, older ])
      expect(result).not_to include(archived)
    end

    it "returns archived posts when status is archived" do
      posted = build_post(title: "Posted", created_at: Time.zone.parse("2024-05-01"))
      archived = build_post(title: "Archived", created_at: Time.zone.parse("2024-05-02"), archived: true)

      result = filter_with(status: "archived")

      expect(result).to match_array([ archived ])
      expect(result).not_to include(posted)
    end

    it "returns posts matching ANY selected tags (OR) and de-duplicates when a post has multiple tags" do
      travel_only = build_post(title: "Travel Only", created_at: Time.zone.parse("2024-05-01"), tags: [ tag_a ])
      work_only = build_post(title: "Work Only", created_at: Time.zone.parse("2024-05-02"), tags: [ tag_b ])
      both = build_post(title: "Both Tags", created_at: Time.zone.parse("2024-05-03"), tags: [ tag_a, tag_b ])

      result = filter_with(tags: [ tag_a.id, tag_b.id ])

      expect(result).to match_array([ both, work_only, travel_only ])
    end

    it "ignores tags belonging to another user" do
      _user_post = build_post(title: "User Post", created_at: Time.zone.parse("2024-05-04"))
      result = filter_with(tags: [ other_tag.id ])
      expect(result).to be_empty
    end

    it "applies start_date inclusively on created_at" do
      before = build_post(title: "Before", created_at: Time.zone.parse("2024-05-01"))
      on = build_post(title: "On", created_at: Time.zone.parse("2024-05-02"))
      after = build_post(title: "After", created_at: Time.zone.parse("2024-05-03"))

      result = filter_with(start_date: "2024-05-02")

      expect(result).to match_array([ after, on ])
      expect(result).not_to include(before)
    end

    it "applies end_date inclusively on created_at" do
      before = build_post(title: "Before", created_at: Time.zone.parse("2024-05-01"))
      on = build_post(title: "On", created_at: Time.zone.parse("2024-05-02"))
      after = build_post(title: "After", created_at: Time.zone.parse("2024-05-03"))

      result = filter_with(end_date: "2024-05-02")

      expect(result).to match_array([ on, before ])
      expect(result).not_to include(after)
    end

    it "applies both start and end dates inclusively" do
      before = build_post(title: "Before", created_at: Time.zone.parse("2024-05-01"))
      in_range = build_post(title: "In Range", created_at: Time.zone.parse("2024-05-05"))
      after = build_post(title: "After", created_at: Time.zone.parse("2024-05-10"))

      result = filter_with(start_date: "2024-05-02", end_date: "2024-05-07")

      expect(result).to match_array([ in_range ])
      expect(result).not_to include(before, after)
    end

    it "ignores invalid date params and falls back to no date filtering" do
      p1 = build_post(title: "P1", created_at: Time.zone.parse("2024-05-01"))
      p2 = build_post(title: "P2", created_at: Time.zone.parse("2024-05-02"))

      result = filter_with(start_date: "not-a-date", end_date: "also-bad")

      expect(result).to match_array([ p2, p1 ])
    end
  end
end
