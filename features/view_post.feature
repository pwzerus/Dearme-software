Feature: Post view

As a logged in user
I want to view my created post
So that I can recall my past experiences

Background:
  Given I am signed in with Google
  And a post exists with:
    | title         | Holidays              |
    | creator_email | test-user@example.com |
    | images        | test_jpg_image.jpg    |

Scenario: User views a post with attached image
  When I visit the view post page for "Holidays"
  Then I should see "Holidays"
  Then I should see "test-user@example.com"
  Then I should see images attached to "Holidays" post
