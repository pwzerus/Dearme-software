Feature: Filtering posts in feeds
  As a feed viewer
  I want to filter posts by tag and date
  So I can focus on the posts I need

  Background:
    Given I am signed in with Google
    And a user exists with:
      | email      | altair@assasin.com |
      | first_name | Altair             |
      | last_name  | Assasin            |
    And a post exists with:
      | creator_email | test-user@example.com |
      | title         | Trip Prep             |
      | tags          | Travel                |
      | archived      | false                 |
      | created_at    | 2024-05-01            |
    And a post exists with:
      | creator_email | test-user@example.com |
      | title         | Office Update         |
      | tags          | Work                  |
      | archived      | false                 |
      | created_at    | 2024-05-02            |
    And a post exists with:
      | creator_email | altair@assasin.com |
      | title         | Trail Journal      |
      | tags          | Hiking             |
      | archived      | false              |
      | created_at    | 2024-05-10         |
    And a post exists with:
      | creator_email | altair@assasin.com |
      | title         | Cafe Notes         |
      | tags          | Food               |
      | archived      | false              |
      | created_at    | 2024-05-20         |

  Scenario: Filter my feed by a single tag
    Given I have access to the feed of user "test-user@example.com"
    When I visit the feed page for user "test-user@example.com"
    And I expand the feed filters
    And I select the tag filter "Travel"
    And I apply the feed filters
    Then I should see "Trip Prep"
    And I should not see "Office Update"
    And the tag filter "Travel" should be checked

  Scenario: Filter a shared feed by multiple tags (OR)
    Given I have access to the feed of user "altair@assasin.com"
    When I visit the feed page for user "altair@assasin.com"
    And I expand the feed filters
    And I select the tag filter "Hiking"
    And I select the tag filter "Food"
    And I apply the feed filters
    Then I should see "Trail Journal"
    And I should see "Cafe Notes"
    And the tag filter "Hiking" should be checked
    And the tag filter "Food" should be checked

  Scenario: Filter my feed by date range (inclusive)
    Given I have access to the feed of user "test-user@example.com"
    When I visit the feed page for user "test-user@example.com"
    And I expand the feed filters
    And I set the start date filter to "2024-05-02"
    And I set the end date filter to "2024-05-10"
    And I apply the feed filters
    Then I should see "Office Update"
    And I should not see "Trip Prep"

  Scenario: Filter a shared feed with only a start date
    Given I have access to the feed of user "altair@assasin.com"
    When I visit the feed page for user "altair@assasin.com"
    And I expand the feed filters
    And I set the start date filter to "2024-05-15"
    And I apply the feed filters
    Then I should see "Cafe Notes"
    And I should not see "Trail Journal"
