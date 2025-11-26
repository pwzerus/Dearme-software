Feature: Google sign in and dashboard access
  As a user
  I want to sign in with Google
  So that I can see the dashboard

  Scenario: Redirect to login when not signed in
    When I visit the dashboard page
    Then I should be on the login page
    And I should see "Login required!"

  Scenario: Successful sign in with Google
    Given a valid Google OAuth response
    When I visit the login page
    And I click "Continue with Google"
    Then I should be on the dashboard page
    And I should see "Welcome Test!"
    And I should see "User Account"

  Scenario: Logout after signing in
    Given I am signed in with Google
    When I visit the user account page
    And I click "Log out"
    Then I should be on the login page
    And I should see "Logged out successfully!"
    And I should see "Continue with Google"

  Scenario: Google sign in fails
    Given Google returns an authentication error
    When I visit the login page
    And I click "Continue with Google"
    Then I should be on the login page
    And I should see "Authentication failed"
