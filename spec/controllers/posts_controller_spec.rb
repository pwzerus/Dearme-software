require "rails_helper"

# These shared example files should be in the same
# directory as this test file.
require_relative "posts_controller_non_existent_post_shared_examples"
require_relative "posts_controller_validate_against_non_creator_shared_examples"

RSpec.describe PostsController, type: :controller do
  let(:test_user) {
    User.create!(
            first_name: "Solid",
            last_name: "Snake",
            email: "solidsnake@liquid.com"
            )
  }

  let(:test_post) {
    Post.create!(creator: test_user,
                 title: "Some post")
  }

  let(:test_image_file) {
    fixture_file_upload("test_jpg_image.jpg",
                        "image/jpeg")
  }

  let(:test_video_file) {
    fixture_file_upload("test_mp4_video.mp4",
                        "video/mp4")
  }

  let(:test_audio_file) {
    fixture_file_upload("test_mp3_audio.mp3",
                        'audio/mp3')
  }

  before do
    # Let test_user be the logged in user
    allow_any_instance_of(ApplicationController)
     .to receive(:current_user).and_return(test_user)
  end

  describe "POST #create" do
    it "should create a new post with some title" do
      expect {
        post :create
      }.to change(Post, :count).by(1)
    end

    it "should redirect to the created post on successful creation" do
      post :create
      expect(response).to redirect_to(post_path(Post.last))
    end

    it "should set flash notice before redirect" do
      post :create
      expect(flash[:notice]).not_to be_nil
    end

    context "Post creation fails" do
      before do
        allow_any_instance_of(Post).to receive(:save).and_return(false)
      end

      it "should redirect to the dashboard path" do
        post :create
        expect(response).to redirect_to(dashboard_path)
      end

      it "should set flash alert before redirect" do
        post :create
        expect(flash[:alert]).not_to be_nil
      end
    end
  end

  describe "#show" do
    http_method = :get
    action = :show

    include_examples "handling of non existent post id", http_method, action

    it "should allow the user to view the post if creator" do
      get :show, params: { id: test_post.id }
      expect(response).to have_http_status(:ok)
    end

    context "current user is not the post creator" do
      let(:non_creator_user) {
          User.create!(
                  email: "non_creator_" + test_post.creator.email,
                  first_name: "Non",
                  last_name: "Creator"
                  )
      }

      before do
        # Let non creator user be the logged in user
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user).and_return(non_creator_user)
      end

      context "current user is mentioned in the post" do
        before do
          test_post.mentioned_users <<  non_creator_user
        end

        it "should show the post" do
          get :show, params: { id: test_post.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context "current user can view feed of the creator" do
        before do
          UserViewUser.create!(
                  viewer: non_creator_user,
                  viewee: test_post.creator,
                  expires_at: Time.current + 5.minutes
                  )
        end

        it "should show the post" do
          get :show, params: { id: test_post.id }
          expect(response).to have_http_status(:ok)
        end
      end

      # Neither creator nor mentioned nor has feed access
      it "should not allow the unmentioned and no feed access non creator to view the post" do
        get :show, params: { id: test_post.id }
        expect(flash[:alert]).not_to be_nil
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "#edit" do
    # Defining let variables for these isn't helpful since I
    # want to use them directly inside describe block for include_examples.
    # (let variables are only available inside it, before, after blocks for
    # usage)
    http_method = :get
    action = :edit

    include_examples "handling of non existent post id", http_method, action
    include_examples "validate against post handling by non creator",
                     http_method, action
  end

  describe "#update" do
    # Defining let variables for these isn't helpful since I
    # want to use them directly inside describe block for include_examples.
    # (let variables are only available inside it, before, after blocks for
    # usage)
    http_method = :patch
    action = :update

    include_examples "handling of non existent post id", http_method, action
    include_examples "validate against post handling by non creator",
                     http_method, action

    let(:edit_test_post) { test_post }

    let(:added_files_params) {
        [ test_image_file, test_video_file ]
    }

    let(:edited_post_params) {
      {
        title: (edit_test_post.title || "") + "EDIT",
        description: (edit_test_post.description || "") + "EDIT",
        archived: !edit_test_post.archived
      }
    }

    it "actually updates the post" do
      patch :update, params: {
                      id: edit_test_post,
                      post: edited_post_params
                    }
      expect(assigns(:post)).to eq(edit_test_post)

      edit_test_post.reload

      expect(edit_test_post.title).to eq(edited_post_params[:title])
      expect(edit_test_post.description).to eq(edited_post_params[:description])
      expect(edit_test_post.archived).to eq(edited_post_params[:archived])
    end

    it "adds new media files when asked to" do
      files_to_add = [ test_audio_file, test_video_file ]
      patch :update, params: {
                       id: edit_test_post,
                       post: edited_post_params,
                       added_files: files_to_add
                     }

      edit_test_post.reload

      post_media_file_names = edit_test_post.media_files.map do |mf|
          mf.file.filename.to_s
      end

      expect(post_media_file_names).to match_array(
              files_to_add.map { |upload_file| upload_file.original_filename }
              )
    end

    context "post with existing media files" do
      let(:existing_upload_file) { test_audio_file }
      let(:existing_media_file) {
        edit_test_post.media_files.create!(
          file: existing_upload_file,
          file_type: MediaFile.type_from_content_type(
                       existing_upload_file.content_type
                     )
          )
      }

      let(:edited_post_params_remove_mf) {
          edited_post_params.merge!(
            media_files_attributes: [
              { id: existing_media_file.id, _destroy: "1" }
            ]
          )
      }

      it "removes the existing media files when asked to" do
        patch :update, params: {
                      id: edit_test_post.id,
                      post: edited_post_params_remove_mf
                    }

        edit_test_post.reload

        post_media_file_names = edit_test_post.media_files.map do |mf|
          mf.file.filename.to_s
        end

        expect(post_media_file_names)
          .not_to include(existing_upload_file.original_filename)
      end
    end

    it "redirects to the post page after the update" do
      patch :update, params: {
                      id: edit_test_post.id,
                      post: edited_post_params
                    }
      expect(response).to redirect_to(post_path(edit_test_post))
    end

    it "sets the flash notice after the update" do
       patch :update, params: {
                      id: edit_test_post.id,
                      post: edited_post_params
                    }
       expect(flash[:notice]).not_to be_nil
    end

    context "update fails" do
      before do
        allow_any_instance_of(Post)
          .to receive(:update!)
          .and_raise(StandardError)
      end

      it "should set flash alert" do
        patch :update, params: {
                      id: edit_test_post.id,
                      post: edited_post_params
                    }
        expect(flash[:alert]).not_to be_nil
      end

      it "should redirect to the dashboard path" do
        patch :update, params: {
                      id: edit_test_post.id,
                      post: edited_post_params
                    }
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "#destroy" do
    # Defining let variables for these isn't helpful since I
    # want to use them directly inside describe block for include_examples.
    # (let variables are only available inside it, before, after blocks for
    # usage)
    http_method = :delete
    action = :destroy

    include_examples "handling of non existent post id", http_method, action
    include_examples "validate against post handling by non creator",
                     http_method, action

    it "should actually destroy the post" do
      # Its important to use test_post before the upcoming expect { }
      # block to initialize test_post (lazy initialization using let) and
      # make Post.count = 1 before that expect block, so that
      # the expect block's code changes it to 0 and the expectation passes
      #
      # If we don't do that and write test_post.id against params: {id: }
      # then the Post.count would go from 0 to 1 in the expect block due to
      # test_post being initialized due to its first use and then
      # destroy would reduce it back from 1 to 0, changing the Post.count
      # before expect block (i.e. 0) to 0 (i.e not really changing anything),
      # which will not pass the expectation.
      delete_id = test_post.id
      expect {
        delete :destroy, params: { id: delete_id }
      }.to change(Post, :count).by(-1)

      expect {
        Post.find(delete_id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "destruction fails" do
      before do
        allow_any_instance_of(Post)
          .to receive(:destroy!)
          .and_raise(StandardError)
      end

      it "should redirect to the dashboard" do
        delete :destroy, params: { id: test_post.id }
        expect(response).to redirect_to(dashboard_path)
      end

      it "should set the flash alert" do
        delete :destroy, params: { id: test_post.id }
        expect(flash[:alert]).not_to be_nil
      end
    end
  end

  describe "#index" do
    let(:mock_filtered_posts) { [ test_post ] }

    before do
      # initialize some tags against the test user
      Tag.create!(title: "INDEX Tag 1", creator: test_user)
      Tag.create!(title: "INDEX Tag 2", creator: test_user)

      allow(controller)
        .to receive(:filter_posts_of)
        .with(test_user).and_return(mock_filtered_posts)
    end

    it "should show the index page" do
      get :index
      expect(assigns(:user)).to eq(test_user)
      expect(assigns(:user_tags)).to eq(test_user.tags.order(:title))
      expect(assigns(:filter_url)).to eq(posts_path)
      expect(assigns(:posts)).to match_array(mock_filtered_posts)
    end
  end
end
