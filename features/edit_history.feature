Feature: Edit history
  As a user
  I can edit my tree and then view the edit history
  So that I can remember what I did

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with the following nodes:
      | id   | parent_id | name                |
      | 100  | 0         | Pardosa             |
    And I go to the master tree page for "Spiders"
    And I wait for the websocket to activate

  @javascript
  Scenario: User can edit the tree then see the edit history
    When I select the node "Pardosa"
    And I follow "File" within "toolbar"
    And I follow "Add single node" within "toolbar"
    And I enter "Pardosa moesta" in the new node and press enter
    And I refresh the master tree
    And I wait for the tree to load
    And I follow "View" within "toolbar"
    And I follow "Edit history" within "toolbar"
    Then I should be on the edit history page for "Spiders"
    And I should see "Edit History for Spiders"
    And I should see "Pardosa moesta added under Pardosa"
    And I should see "email@person.com"