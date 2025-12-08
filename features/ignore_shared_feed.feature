Feature: Ignore shared user feed

As a logged in user
I want to ignore a feed shared with me
So that I can manage the feeds shared with me

Background:
  Given I am signed in with Google
  And a user exists with:
    | email      | altair@assasin.com       |
    | first_name | Altair                   |
    | last_name  | Assasin                  |
  And a user exists with:
    | email      | ezio@assasin.com         |
    | first_name | Ezio                     |
    | last_name  | Assasin                  |
  And I visit the feed share link of user "altair@assasin.com"
  And I visit the feed share link of user "ezio@assasin.com"

Scenario: User ignores shared feed of another user
  Given I visit the shared user feeds page
  When I click to ignore shared feed of user "altair@assasin.com"
  Then I should be on the shared user feeds page
  And I should see "Stopped feed share successfully !"
  And I should not see "altair@assasin.com"
  And I should see "ezio@assasin.com"
