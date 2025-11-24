Feature: Post creation

As a logged in user
I want to create a post
So that I can capture the events of my life in it

Background:
  Given I am signed in with Google

Scenario: User creates a post
  Given I visit the dashboard page
  When I click "Create Post"
  Then I should see a new post created with defaults
