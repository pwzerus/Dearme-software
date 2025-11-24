Feature: Post edit

As a logged in user
I want to edit my created post
So that I can update or correct its details

Background:
  Given I am signed in with Google
  And a post exists with:
    | title         | Holidays              |
    | creator_email | test-user@example.com |
    | images        | test_jpg_image.jpg    |
  And a post exists with:
    | title         | No attached images    |
    | creator_email | test-user@example.com |

Scenario: User visits the edit page
  When I visit the view post page for "Holidays"
  And I click "Edit"
  Then I should be on the edit post page for "Holidays"

Scenario: User edits the post title
  Given I visit the edit post page for "Holidays"
  When I edit post title to "End of Holidays"
  And I click "Update"
  Then I should be on the view post page for "End of Holidays"
  Then I should see "End of Holidays"

Scenario: User edits the post description
  Given I visit the edit post page for "Holidays"
  When I edit post description to "Its the end of holidays !"
  And I click "Update"
  Then I should be on the view post page for "Holidays"
  And I should see "Its the end of holidays !"

Scenario: User attaches an image to the post
  Given I visit the edit post page for "Holidays"
  When I attach the following media files to the post:
    | test_png_image.png |
  And I click "Update"
  Then I should be on the view post page for "Holidays"
  And I should see the "test_png_image.png" image

Scenario: User attached multiple images to a post
  Given I visit the edit post page for "No attached images"
  When I attach the following media files to the post:
    | test_jpg_image.jpg |
    | test_png_image.png |
  And I click "Update"
  Then I should be on the view post page for "No attached images"
  And I should see the "test_jpg_image.jpg" image
  And I should see the "test_png_image.png" image
