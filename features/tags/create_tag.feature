Feature: Create a new tag
  As a user
  I want to create a new tag with a name
  So that I can filter my post feed by tags

  Scenario: Successfully create a new tag
    Given I am signed in with Google
    And I do not already have a tag named "Travel"
    When I create a new tag named "Travel"
    Then I should see "Travel" in my list of tags

  Scenario: Fail to create a tag with a blank name
    Given I am signed in with Google
    When I attempt to create a new tag with no name
    Then I should see an error that the tag name cannot be blank
    And the tag should not be created

  Scenario: Fail to create a tag with a duplicate name
    Given I am signed in with Google
    And I already have a tag named "Travel"
    When I create a new tag named "Travel"
    Then I should see an error that the tag name has already been taken
    And the tag should not be duplicated

  Scenario: Create a tag with the same name as another user
    Given another user already has a tag named "Travel"
    And I am signed in with Google
    And I do not already have a tag named "Travel"
    When I create a new tag named "Travel"
    Then I should see "Travel" in my list of tags
