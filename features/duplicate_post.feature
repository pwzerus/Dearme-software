Feature: Post duplication

  As a logged in user
  I want to duplicate my own posts
  And copy posts created by other users that I can view
  So that I can manage my own copies of those posts

  Background:
    Given I am signed in with Google

  Scenario: User duplicates their own post
    And a post exists with:
      | title         | My Holiday            |
      | creator_email | test-user@example.com |
    When I visit the view post page for "My Holiday"
    And I click "Duplicate"
    Then a post should exist with:
      | title         | Copy of My Holiday    |
      | creator_email | test-user@example.com |
    And I should be on the edit post page for "Copy of My Holiday"

  Scenario: User copies a post created by another user
    And a user exists with:
      | email      | other-user@example.com |
      | first_name | Other                  |
      | last_name  | User                   |
    And a post exists with:
      | title         | Road Trip              |
      | creator_email | other-user@example.com |
    And I have feed access to posts created by "other-user@example.com"
    When I visit the view post page for "Road Trip"
    And I click "Copy to my posts"
    Then a post should exist with:
      | title         | Copy of Road Trip      |
      | creator_email | test-user@example.com  |
    And I should be on the edit post page for "Copy of Road Trip"

  Scenario: User is redirected when trying to copy a non existent post
    When I attempt to copy a post that does not exist
    Then I should be on the dashboard page
    And I should see "Failed to find post"

  Scenario: User cannot copy another user's post without permission
    And a user exists with:
      | email      | other-user@example.com |
      | first_name | Other                  |
      | last_name  | User                   |
    And a post exists with:
      | title         | Secret Trip             |
      | creator_email | other-user@example.com |
    When I attempt to copy the post titled "Secret Trip" without permission
    Then I should be on the dashboard page
    And I should see "You do not have access to copy this post"

