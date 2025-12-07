Feature: Filtering by post status on feeds
  As a feed viewer
  I want to switch between posted and archived posts on my own feed
  And not see that switch on shared feeds

  Background:
    Given I am signed in with Google
    And a user exists with:
      | email      | altair@assasin.com |
      | first_name | Altair             |
      | last_name  | Assasin            |
    And a post exists with:
      | creator_email | test-user@example.com |
      | title         | Posted Post           |
      | archived      | false                 |
    And a post exists with:
      | creator_email | test-user@example.com |
      | title         | Archived Post         |
      | archived      | true                  |
    And a post exists with:
      | creator_email | altair@assasin.com |
      | title         | Friend Archived    |
      | archived      | true               |

  Scenario: Switching to archived shows archived posts on my feed
    Given I have access to the feed of user "test-user@example.com"
    When I visit the feed page for user "test-user@example.com"
    And I expand the feed filters
    And I select the status filter "archived"
    And I apply the feed filters
    Then I should see "Archived Post"
    And I should not see "Posted Post"

  Scenario: Default status shows posted posts on my feed
    Given I have access to the feed of user "test-user@example.com"
    When I visit the feed page for user "test-user@example.com"
    Then I should see "Posted Post"
    And I should not see "Archived Post"

  Scenario: Shared feed does not show the status filter
    Given I have access to the feed of user "altair@assasin.com"
    When I visit the feed page for user "altair@assasin.com"
    And I expand the feed filters
    Then I should not see a status filter
    And I should not see "Friend Archived"
