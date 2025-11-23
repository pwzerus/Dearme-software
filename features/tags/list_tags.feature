Feature: View my tags
  As a user
  I want to see a list of all tags I have created
  So that I can quickly choose, edit, or delete them

  Scenario: See all my tags in the list
    Given I am signed in with Google
    And I already have a tag named "Travel"
    And I already have a tag named "Food"
    And I already have a tag named "Work"
    When I visit the tags page
    Then I should see "Travel" in my list of tags
    And I should see "Food" in my list of tags
    And I should see "Work" in my list of tags

  Scenario: I cannot see other users' tags
    Given I am signed in with Google
    And I already have a tag named "Travel"
    And another user already has a tag named "Secret"
    When I visit the tags page
    Then I should see "Travel" in my list of tags
    And I should not see "Secret" in my list of tags
