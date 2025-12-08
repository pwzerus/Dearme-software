Feature: Revoke shared feed access

As a logged in user
I want to revoke feed access provided to others
So that I can manage the people who can view my feed

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

Scenario: User feed can not be accessed by anyone
  When I visit the feed share manager page
  Then I should see "No user is accessing your feed"

Scenario: User views users who can access feed
  Given user "altair@assasin.com" has view access to my feed
  Given user "ezio@assasin.com" has view access to my feed
  When I visit the feed share manager page
  Then I should see "altair@assasin.com"
  Then I should see "ezio@assasin.com"

Scenario: User revokes feed access of another user
  Given user "altair@assasin.com" has view access to my feed
  When I visit the feed share manager page
  And I click to revoke feed access of user "altair@assasin.com"
  Then I should be on the feed share manager page
  And I should see "Stopped feed share successfully !"
  And I should not see "altair@assasin.com"
