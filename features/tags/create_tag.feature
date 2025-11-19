Feature: Create a new tag
  As a user
  I want to create a new tag with a name
  So that I can filter my post feed by tags

  Scenario: Successfully create a new tag
    Given I am logged in
    And I do not already have a tag named "Travel"
    When I create a new tag named "Travel"
    Then I should see "Travel" in my list of tags