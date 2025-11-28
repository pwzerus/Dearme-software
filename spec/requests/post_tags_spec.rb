require "rails_helper"

RSpec.describe "PostTags", type: :request do
  describe "POST /post_tags" do
    let(:user) do
      User.create!(
        email: "rspec_user@example.com",
        first_name: "RSpec",
        last_name: "User"
      )
    end

    before do
      # Pretend the user is logged in for all actions
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user)
        .and_return(user)
    end

    let(:post_record) do 
      Post.create!( 
        creator: user,
        title: "RSpec Post"
      )
    end
    
    let(:tag) do
      Tag.create!(
        creator: user,
        title: "RSpec Tag"
      )
    end

    it "creates a tag association between a post and a tag for the same user" do
      expect {
        post post_tags_path, params: {
          post_tag: {
            post_id: post_record.id,
            tag_id: tag.id
          }
        }
      }.to change(PostTag, :count).by(1)

      created = PostTag.last
      expect(created.post).to eq(post_record)
      expect(created.tag).to eq(tag)

      # Adjust expectation to match how you plan to respond:
      expect(response).to redirect_to(post_path(post_record))
      follow_redirect!

      # Optional: sanity check that the page renders successfully
      expect(response).to have_http_status(:ok)
    end

    it "does not allow a user to tag a post they do not own" do
      other_user = User.create!(
        email: "other_user@example.com",
        first_name: "Other",
        last_name: "User"
      )

      other_post = Post.create!(
        creator: other_user,
        title: "Other User Post"
      )

      user_tag = Tag.create!(
        creator: user,
        title: "User Tag"
      )

      # Ensure no PostTag is instantiated
      expect(PostTag).not_to receive(:new)

      expect {
        post post_tags_path, params: {
          post_tag: {
            post_id: other_post.id,
            tag_id: user_tag.id
          }
        }
      }.not_to change(PostTag, :count)

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Not Found").or include("not found")
    end
    it "does not allow a user to use a tag they do not own" do
      # current_user (from let(:user)) owns this post
      user_post = Post.create!(
        creator: user,
        title: "User's Post"
      )

      # other_user owns this tag
      other_user = User.create!(
        email: "other_tag_owner@example.com",
        first_name: "Other",
        last_name: "TagOwner"
      )

      other_tag = Tag.create!(
        creator: other_user,
        title: "Other User Tag"
      )

      # The controller should fail before ever building a PostTag
      expect(PostTag).not_to receive(:new)

      expect {
        post post_tags_path, params: {
          post_tag: {
            post_id: user_post.id,
            tag_id: other_tag.id
          }
        }
      }.not_to change(PostTag, :count)

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Not Found").or include("not found")
    end

    it "does not create a duplicate association for the same post and tag" do
      # First, create an existing association between this post and tag
      existing = PostTag.create!(post: post_record, tag: tag)

      expect(PostTag.where(post: post_record, tag: tag)).to exist

      # Now attempt to create the same association again via the controller
      expect {
        post post_tags_path, params: {
          post_tag: {
            post_id: post_record.id,
            tag_id: tag.id
          }
        }
      }.not_to change(PostTag, :count)

      # We still want to land back on the post page (idempotent behavior)
      expect(response).to redirect_to(post_path(post_record))
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end
  end
  describe "DELETE /post_tags/:id" do
    let(:user) do
      User.create!(
        email: "rspec_user@example.com",
        first_name: "RSpec",
        last_name: "User"
      )
    end

    before do
      allow_any_instance_of(ApplicationController)
        .to receive(:current_user)
        .and_return(user)
    end

    let(:post_record) do 
      Post.create!( 
        creator: user,
        title: "RSpec Post"
      )
    end
    
    let(:tag) do
      Tag.create!(
        creator: user,
        title: "RSpec Tag"
      )
    end
    
    it "allows the owner to remove a tag from their post" do
      post_tag = PostTag.create!(post: post_record, tag: tag)

      expect(PostTag.where(id: post_tag.id)).to exist
      expect(post_record.tags).to include(tag)

      expect {
        delete post_tag_path(post_tag)
      }.to change(PostTag, :count).by(-1)

      # Reload the post to check the association is really gone
      expect(post_record.reload.tags).not_to include(tag)

      expect(response).to redirect_to(post_path(post_record))
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end
  end
end
