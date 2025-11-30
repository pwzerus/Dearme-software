# spec/requests/posts_spec.rb
require "rails_helper"

RSpec.describe "PostsController", type: :request do
  let(:user) do
    User.create!(
      email: "posts_user@example.com",
      first_name: "Posts",
      last_name: "User"
    )
  end

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user)
      .and_return(user)
  end

  describe "POST /posts" do
    it "creates a post for the current user and redirects to its show page" do
      expect {
        post posts_path
      }.to change(Post, :count).by(1)

      created = Post.last
      expect(created.creator).to eq(user)

      expect(response).to redirect_to(post_path(created))
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end

    it "handles save failures and redirects to the dashboard with a message" do
      errors_double = double(full_messages: ["something went wrong"])
      invalid_post  = instance_double(
        Post,
        save: false,
        errors: errors_double
      )

      # Force the controller into the failure branch for create
      allow(Post).to receive(:new).and_return(invalid_post)

      expect {
        post posts_path
      }.not_to change(Post, :count)

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:notice]).to include("Failed to create a post")
    end
  end

  describe "GET /posts/:id" do
    it "shows a post that exists and belongs to the current user" do
      post_record = Post.create!(
        creator: user,
        title: "Show me",
        description: "Show description"
      )

      get post_path(post_record)

      expect(response).to have_http_status(:ok)
    end

    it "redirects to dashboard with an error when the post does not exist" do
      nonexistent_id = 999_999
      expect(Post.where(id: nonexistent_id)).not_to exist

      get post_path(nonexistent_id)

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:error]).to include("Failed to find post")
    end
  end

  describe "GET /posts/:id/edit" do
    it "renders the edit page for the post creator" do
      post_record = Post.create!(
        creator: user,
        title: "Editable",
        description: "Edit me"
      )

      get edit_post_path(post_record)

      expect(response).to have_http_status(:ok)
    end

    it "redirects non-creators who try to edit a post" do
      other_user = User.create!(
        email: "other_user@example.com",
        first_name: "Other",
        last_name: "User"
      )

      others_post = Post.create!(
        creator: other_user,
        title: "Other user's post"
      )

      get edit_post_path(others_post)

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:alert]).to eq("Not the post creator, operation now allowed !")
    end
  end

  describe "PATCH /posts/:id" do
    let!(:post_record) do
      Post.create!(
        creator: user,
        title: "Original title",
        description: "Original description",
        archived: false
      )
    end

    it "updates attributes and redirects to the post show page" do
      patch post_path(post_record), params: {
        post: {
          title: "Updated title",
          description: "Updated description",
          archived: "0"
        }
      }

      expect(response).to redirect_to(post_path(post_record))
      expect(flash[:notice]).to eq("Post updated successfully")

      post_record.reload
      expect(post_record.title).to eq("Updated title")
      expect(post_record.description).to eq("Updated description")
      expect(post_record.archived).to eq(false)
    end

    it "creates media files when added_files param is present" do
      Tempfile.create(["upload", ".png"]) do |tempfile|
        tempfile.write("fake image content")
        tempfile.rewind

        uploaded_file = Rack::Test::UploadedFile.new(tempfile.path, "image/png")

        media_assoc = double("MediaFilesAssociation")
        expect(media_assoc).to receive(:create!).with(
          hash_including(file: kind_of(ActionDispatch::Http::UploadedFile), file_type: "image")
        )

        # When the controller calls @post.media_files.create!(...), use our double
        allow_any_instance_of(Post)
          .to receive(:media_files)
          .and_return(media_assoc)

        # Also stub MediaFile.type_from_content_type to avoid depending on its impl
        allow(MediaFile).to receive(:type_from_content_type).and_return("image")

        patch post_path(post_record), params: {
          post: {
            title: "With new media"
          },
          added_files: [uploaded_file]
        }

        expect(response).to redirect_to(post_path(post_record))
        expect(flash[:notice]).to eq("Post updated successfully")
      end
    end

    it "rescues from errors during update and redirects to dashboard" do
      allow_any_instance_of(Post)
        .to receive(:update!)
        .and_raise(StandardError.new("boom"))

      patch post_path(post_record), params: {
        post: {
          title: "Should fail"
        }
      }

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:error]).to include("Failed to update the post")
    end
  end

  describe "DELETE /posts/:id" do
    let!(:post_record) do
      Post.create!(
        creator: user,
        title: "Destroy me"
      )
    end

    it "destroys the post and redirects to the dashboard" do
      expect {
        delete post_path(post_record)
      }.to change(Post, :count).by(-1)

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:notice]).to eq("Post destroyed successfully")
    end

    it "rescues from errors on destroy and redirects with an error message" do
      allow_any_instance_of(Post)
        .to receive(:destroy!)
        .and_raise(StandardError.new("explode"))

      expect {
        delete post_path(post_record)
      }.not_to change(Post, :count)

      expect(response).to redirect_to(dashboard_path)
      expect(flash[:error]).to include("Failed to destroy the post")
    end
  end
end
