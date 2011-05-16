Feature: Manage bookmarks
  As a user
  I can manage bookmarks
  So that I can quickly navigate to stored places

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with the following nodes:
      | id   | parent_id | name                |
      | 100  | 0         | Pardosa             |
      | 101  | 100       | Pardosa distincta   |
      | 102  | 100       | Pardosa moesta      |
      | 103  | 100       | Pardosa xerampelina |
    And there is an existing bookmark called "First bookmark" for a node "Pardosa distincta"
    And there is an existing bookmark called "Second bookmark" for a node "Pardosa moesta"
    And I am on the master tree index page
    When I follow "Spiders"
    And I wait for the tree to load

  @javascript
  Scenario: User can see a bookmark associated with nodes in the master tree
    When I follow "Bookmarks" within "toolbar"
    And I follow "Show bookmarks" within "toolbar"
    And I wait for the bookmark results to load
    Then I should see a bookmark "First bookmark" in master tree bookmarks
    And I should see a bookmark "Second bookmark" in master tree bookmarks

  @javascript
  Scenario: User can add a bookmark to a node in the master tree from the toolbar
    When I expand the node "Pardosa"
    And I select the node "Pardosa xerampelina"
    And I follow "Bookmarks" within "toolbar"
    And I follow "Add bookmark" within "toolbar"
    And I wait for the bookmark form to load
    And I fill in "Name" with "My bookmark"
    And I press "Add bookmark"
    And I follow "Show bookmarks" within "toolbar"
    And I wait for the bookmark results to load
    Then I should see a bookmark "My bookmark" in master tree bookmarks

  @javascript
  Scenario: User can click a bookmark in the master tree and have searched name highlighted
    And I follow "Bookmarks" within "toolbar"
    And I follow "Show bookmarks" within "toolbar"
    And I wait for the bookmark results to load
    And I follow "First bookmark"
    And I wait for the tree to load
    Then I should see a node "Pardosa distincta" under "Pardosa"
    And the "Pardosa distincta" tree node should be selected

  @javascript
  Scenario: User can add a bookmark using the context menu in the master tree
    When I expand the node "Pardosa"
    And I select the node "Pardosa xerampelina"
    And I click "Add bookmark" in the context menu
    And I wait for the bookmark form to load
    And I fill in "Name" with "My bookmark"
    And I press "Add bookmark"
    And I follow "Bookmarks" within "toolbar"
    And I follow "Show bookmarks" within "toolbar"
    And I wait for the bookmark results to load
    Then I should see a bookmark "My bookmark" in master tree bookmarks

  @javascript
  Scenario: User can delete a bookmark in the master tree
    When I follow "Bookmarks" within "toolbar"
    And I follow "Show bookmarks" within "toolbar"
    And I wait for the bookmark results to load
    And I delete "First bookmark" in master tree bookmarks
    Then I should not see a bookmark "First bookmark" in master tree bookmarks
    And I should see a bookmark "Second bookmark" in master tree bookmarks
    And I click the master tree background
    And I follow "Bookmarks" within "toolbar"
    And I follow "Show bookmarks" within "toolbar"
    And I wait for the bookmark results to load
    Then I should not see a bookmark "First bookmark" in master tree bookmarks
    And I should see a bookmark "Second bookmark" in master tree bookmarks

  @javascript
  Scenario: User can edit a bookmark title in the master tree
    When I follow "Bookmarks" within "toolbar"
    And I follow "Show bookmarks" within "toolbar"
    And I wait for the bookmark results to load
    And I edit "First bookmark" to be "Last bookmark" in master tree bookmarks
    Then I should see a bookmark "Last bookmark" in master tree bookmarks