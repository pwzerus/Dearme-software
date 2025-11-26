Feature: Post deletion

As a logged in user
I want to delete a post
So that I can get rid of posts that I no longer wish to keep

Background:
  Given I am signed in with Google
  And a post exists with:
    | title         | Holidays             |
    | creator_email | test-user@example.com |

Scenario: User deletes an existing post
  Given I visit the view post page for "Holidays"
  And I click "Delete"
  Then I should be on the dashboard page
  And I should see "Post destroyed successfully"
