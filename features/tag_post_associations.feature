Feature: Manage tags for a post from the post edit page
  As a logged-in user
  So that I can keep my posts organized by theme
  I want to add and remove tags for a post while editing that post

  Background:
    Given I am signed in with Google
    And I already have a tag named "Important"
    And a post exists with:
      | title         | First Journal |
    And a post exists with:
      | title          | Second Journal |
    And the post "First Journal" is tagged with "Important"
    And the post "Second Journal" is not tagged with "Important"

  Scenario: Add a tag to a post from the post edit page
    When I visit the edit post page for "Second Journal"
    And I check the tag "Important" for this post
    And I click "Update"
    Then the post "Second Journal" should be tagged with "Important"
    And the post "First Journal" should still be tagged with "Important"

  Scenario: Remove a tag from a post from the post edit page
    When I visit the edit post page for "First Journal"
    And I uncheck the tag "Important" for this post
    And I click "Update"
    Then the post "First Journal" should not be tagged with "Important"
    And the post "Second Journal" should still not be tagged with "Important"

  Scenario: See tags for a post on the show page
    When I visit the view post page for "First Journal"
    Then I should see "Important"
