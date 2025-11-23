Feature: Edit an existing tag
  As a user
  I want to edit an existing tag’s name
  So that I can correct mistakes and keep my tags consistent

  Scenario: Successfully rename a tag
    Given I am signed in with Google
    And I already have a tag named "Travel"
    When I rename the tag "Travel" to "Trips"
    Then I should see "Trips" in my list of tags
    And I should not see "Travel" in my list of tags

  Scenario: Fail to rename a tag to a blank name
    Given I am signed in with Google
    And I already have a tag named "Travel"
    When I rename the tag "Travel" to an empty name
    Then I should see an error that the tag name cannot be blank
    And I should still have a tag named "Travel"

  Scenario: Fail to rename a tag to a duplicate name
    Given I am signed in with Google
    And I already have a tag named "Travel"
    And I already have a tag named "Food"
    When I rename the tag "Food" to "Travel"
    Then I should see an error that the tag name has already been taken
    And I should still have a tag named "Food"
    And I should still have a tag named "Travel"
