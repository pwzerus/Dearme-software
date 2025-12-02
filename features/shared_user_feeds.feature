Feature: Shared user feeds

As a user
I should be able to use the feed share link of another user
So that I can view the other user's feed

Background:
  Given a user exists with:
    | email      | altair@assasin.com       |
    | first_name | Altair                   |
    | last_name  | Assasin                  |

Scenario: Non logged in user uses the feed share link
  Given a valid Google OAuth response
  When I visit the feed share link of user "altair@assasin.com"
  Then I should be on the login page
  When I click to sign in with Google
  Then I should be on the shared user feeds page
  And I should see the shared feed entry for user "altair@assasin.com"

Scenario: Logged in user uses the feed share link
  Given I am signed in with Google
  When I visit the feed share link of user "altair@assasin.com"
  Then I should be on the shared user feeds page
  And I should see the shared feed entry for user "altair@assasin.com"

Scenario: User visits the shared user feed via shared user feeds listing
  Given I am signed in with Google
  When I visit the feed share link of user "altair@assasin.com"
  Then I should be on the shared user feeds page
  When I click to view feed share entry of user "altair@assasin.com"
  Then I should be on the shared feed page for user "altair@assasin.com"
