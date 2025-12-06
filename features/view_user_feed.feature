# This acceptance test covers viewing of both the share user feed
# page and viewing posts index page (test shared because code
# for both features should be shared)
#
# - For logged in user -> the feed page refers to posts INDEX page
# - For some other user -> the feed page refers to the shared feed page
#                          (shared with the logged in user)
#
# In short: Please add tests for VIEWING of posts INDEX page and
# shared feed here !(and you shouldn't need to create separate ones for them)
#
# For other things that are not same for both pages, the tests can be added
# in separate files.

Feature: Viewing a user's feed

As a logged in user,
I should be able to view both my feed and the feeds shared with me
So that I can view all posts I've access to

Background:
  Given I am signed in with Google
  And a user exists with:
    | email      | altair@assasin.com       |
    | first_name | Altair                   |
    | last_name  | Assasin                  |
  And posts exist with following duplicated details for multiple users:
    | creator_emails | test-user@example.com, altair@assasin.com |
    | title          | Test Post 1                               |
    | archived       | false                                     |
  And posts exist with following duplicated details for multiple users:
    | creator_emails | test-user@example.com, altair@assasin.com |
    | title          | Test Post 2                               |
    | archived       | false                                     |

Scenario Outline: Viewing posts of a feed
  Given I have access to the feed of user "<feed_owner_email>"
  When I visit the feed page for user "<feed_owner_email>"
  Then I should see "Test Post 1"
  And I should see "Test Post 2"

  Examples:
    | feed_owner_email      |
    | test-user@example.com |
    | altair@assasin.com    |

Scenario Outline: Visiting a post from the feed
  Given I have access to the feed of user "<feed_owner_email>"
  And I visit the feed page for user "<feed_owner_email>"
  When I click to view post "Test Post 1" from the feed
  Then I should be on the view post page for "Test Post 1" for creator "<feed_owner_email>"

  Examples:
    | feed_owner_email      |
    | test-user@example.com |
    | altair@assasin.com    |
