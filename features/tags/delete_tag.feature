Feature: Delete a tag
  As a user
  I want to delete a tag I no longer need
  So that I can keep my tagging system organized

  Scenario: Successfully delete one of my tags
    Given I am logged in
    And I already have a tag named "Travel"
    And I already have a tag named "Food"
    When I delete the tag "Travel"
    Then I should not see "Travel" in my list of tags
    And I should still have a tag named "Food"