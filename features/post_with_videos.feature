Feature: Post with attached videos

As a logged in user
I want to attach videos to my posts
So that I can associate a post with related videos

Background:
  Given I am signed in with Google
  And a post exists with:
    | title         | Holidays              |
    | creator_email | test-user@example.com |
    | videos        | test_mp4_video.mp4    |
  And a post exists with:
    | title         | No attached videos    |
    | creator_email | test-user@example.com |

Scenario: User views a post with a video
  When I visit the view post page for "Holidays"
  Then I should see the "test_mp4_video.mp4" video

Scenario: User attaches a video to the post
  Given I visit the edit post page for "No attached videos"
  When I attach the following media files to the post:
    | test_mp4_video.mp4 |
  And I click "Update"
  Then I should be on the view post page for "No attached videos"
  And I should see the "test_mp4_video.mp4" video

Scenario: User attaches multiple videos to a post
  Given I visit the edit post page for "No attached videos"
  When I attach the following media files to the post:
    | test_mp4_video.mp4 |
    | test_mov_video.mov |
  And I click "Update"
  Then I should be on the view post page for "No attached videos"
  And I should see the "test_mp4_video.mp4" video
  And I should see the "test_mov_video.mov" video
