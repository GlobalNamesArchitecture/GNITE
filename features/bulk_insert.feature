Feature: Bulk insert nodes into the master tree
  As a user
  I can insert multiple nodes into the master tree
  So that I can more quickly insert data

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with the following nodes:
      | id   | parent_id | name     |
      | 100  | 0         | Hogna    |
    And I go to the master tree page for "Spiders"
    And I wait for the tree to load

  @javascript
  Scenario: Bulk insert as new roots
    When I follow "File" within "toolbar"
    And follow "Add many nodes" within "toolbar"
    And I type the following node names into the bulk insert box:
      | Pardosa    |
      | Schizocosa |
      | Trochosa   |
    And I press "Add children"
    And I wait for the tree to load
    And I refresh the master tree
    Then I should see a node "Pardosa" at the root level in my master tree
    And I should see a node "Schizocosa" at the root level in my master tree
    And I should see a node "Trochosa" at the root level in my master tree

  @javascript
  Scenario: Bulk insert under a parent node
    When I select the node "Hogna"
    And I follow "File" within "toolbar"
    And I follow "Add many nodes" within "toolbar"
    And I type the following node names into the import box:
      | Hogna frondicola |
      | Hogna ruricola   |
    And I press "Add children"
    And I wait for the tree to load
    And I refresh the master tree
    And I expand the node "Hogna"
    Then I should see a node "Hogna frondicola" under "Hogna"
    And I should see a node "Hogna ruricola" under "Hogna"