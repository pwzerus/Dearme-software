Feature: Manage tag associations from the tag edit page
  As a logged-in user
  So that I can keep my posts organized by theme
  I want to add and remove tags from my posts while editing a tag

  Background:
    Given the following user exists:
      | email                 | first_name | last_name |
      | rspec_user@example.com | RSpec      | User      |
    And I am logged in as "rspec_user@example.com"
    And the following posts exist for "rspec_user@example.com":
      | title            |
      | First Journal    |
      | Second Journal   |
    And the following tags exist for "rspec_user@example.com":
      | title      |
      | Important  |
    And the tag "Important" is associated with the post "First Journal"
    And the tag "Important" is not associated with the post "Second Journal"

  Scenario: Add a tag to another post from the tag edit page
    When I visit the edit page for the tag "Important"
    And I check the post "Second Journal" for this tag
    And I submit the tag form
    Then the post "Second Journal" should be tagged with "Important"
    And the post "First Journal" should still be tagged with "Important"

  Scenario: Remove a tag from a post from the tag edit page
    When I visit the edit page for the tag "Important"
    And I uncheck the post "First Journal" for this tag
    And I submit the tag form
    Then the post "First Journal" should not be tagged with "Important"
    And the post "Second Journal" should still not be tagged with "Important"
