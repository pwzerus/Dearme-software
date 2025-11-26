Feature: Manage my account
  As a user
  I want to manage my account
  So that my details and profile picture stay up to date
  And I can delete my account when I no longer need it

  Background:
    And I am signed in with Google

  Scenario: Edit my personal details
    When I visit the user account page
    And I update my name to "NewFirst" "NewLast"
    And I save my account changes
    Then I should see "Profile updated successfully."
    And I should see "NewFirst" on the dashboard

  Scenario: Delete my account
    When I visit the user account page
    And I delete my account
    Then I should be on the login page
    And I should see "Your account has been deleted."

  @profile_picture
  Scenario: Add and then remove my profile picture
    When I visit the user account page
    And I upload a profile picture
    And I save my account changes
    Then I should see my profile picture
    When I remove my profile picture
    And I save my account changes
    Then I should not see any profile picture
