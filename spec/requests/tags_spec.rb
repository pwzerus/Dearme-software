# spec/requests/tags_spec.rb
require "rails_helper"

RSpec.describe "Tags", type: :request do
  # Simple helper user – no FactoryBot needed
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

  describe "GET /tags" do
    it "lists only the current user's tags" do
      my_tag     = Tag.create!(title: "MyTag", creator: user)
      other_user = User.create!(email: "other@example.com", first_name: "Other", last_name: "User")
      Tag.create!(title: "OtherTag", creator: other_user)

      get tags_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("MyTag")
      expect(response.body).not_to include("OtherTag")
    end
  end

  describe "POST /tags" do
    it "creates a tag with valid params" do
      expect {
        post tags_path, params: { tag: { title: "Travel" } }
      }.to change(Tag, :count).by(1)

      tag = Tag.last
      expect(tag.title).to eq("Travel")
      expect(tag.creator).to eq(user)

      expect(response).to redirect_to(tags_path)
      follow_redirect!
      expect(response.body).to include("Tag was successfully created").or include("Travel")
    end

    it "does not create a tag with a blank title" do
      expect {
        post tags_path, params: { tag: { title: "" } }
      }.not_to change(Tag, :count)

      # We expect the index template to be re-rendered with 422
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Title can&#39;t be blank")
    end

    it "does not create a duplicate tag for the same user" do
      Tag.create!(title: "Travel", creator: user)

      expect {
        post tags_path, params: { tag: { title: "Travel" } }
      }.not_to change(Tag, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Title has already been taken")
    end
  end

  describe "PATCH /tags/:id" do
    it "updates a tag with valid params" do
      tag = Tag.create!(title: "OldName", creator: user)

      patch tag_path(tag), params: { tag: { title: "NewName" } }

      expect(response).to redirect_to(tags_path)
      tag.reload
      expect(tag.title).to eq("NewName")
    end

    it "does not update a tag with invalid params" do
      tag = Tag.create!(title: "KeepMe", creator: user)

      patch tag_path(tag), params: { tag: { title: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      tag.reload
      expect(tag.title).to eq("KeepMe")
      expect(response.body).to include("Title can&#39;t be blank")
    end

    it "does not allow updating another user's tag" do
        other_user = User.create!(email: "other@example.com", first_name: "Other", last_name: "User")
        other_tag  = Tag.create!(title: "OtherTag", creator: other_user)

        original_title = other_tag.title

        patch tag_path(other_tag), params: { tag: { title: "Hacked" } }

        expect(other_tag.reload.title).to eq(original_title)

        expect(response).not_to have_http_status(:success)
    end

  end

  describe "DELETE /tags/:id" do
    it "deletes the tag belonging to the current user" do
      tag = Tag.create!(title: "Trash", creator: user)

      expect {
        delete tag_path(tag)
      }.to change(Tag, :count).by(-1)

      expect(response).to redirect_to(tags_path)
    end

    it "does not allow deleting another user's tag" do
        other_user = User.create!(email: "other@example.com", first_name: "Other", last_name: "User")
        other_tag  = Tag.create!(title: "Secret", creator: other_user)

        expect {
            delete tag_path(other_tag)
        }.not_to change(Tag, :count)

        expect(response).not_to have_http_status(:success)
    end

  end
end
