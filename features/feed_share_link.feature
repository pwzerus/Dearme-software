Feature: Share feed link

As a logged in user
I want to provide a share link to others
So that I can share all my posts with them

Background:
  Given I am signed in with Google

Scenario: User views the feed share link
  When I visit the dashboard page
  And I click "Share Feed"
  Then I should see my feed share link
  And I should see the feed share link validity time

Scenario: User clicks on his own feed share link
  When I visit the feed share manager page
  And I click "SHARE FEED LINK"
  Then I should be on the dashboard page
  And I should see "Cannot share feed with self!"
