Feature: Bulk insert nodes into the master tree
  As a user
  I can insert multiple nodes into the master tree
  So that I can more quickly insert data

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | title       |
      | My new tree |
    And the following master tree contributor exists:
      | master tree       | user                   |
      | title:My new tree | email:email@person.com |
    And I go to the master tree page for "My new tree"

  @javascript
  Scenario: Bulk insert as new roots
    And I follow "File" within "toolbar"
    And follow "Add many nodes" within "toolbar"
    And I type the following node names into the import box:
      | Pardosa    |
      | Schizocosa |
      | Trochosa  |
    And I press "Add children"
    And I refresh the master tree
    Then I should see a node "Pardosa" at the root level in my master tree
    And I should see a node "Schizocosa" at the root level in my master tree
    And I should see a node "Trochosa" at the root level in my master tree

  @javascript
  Scenario: Bulk insert under a parent node
    And I follow "File" within "toolbar"
    And follow "Add single node" within "toolbar"
    And I enter "Pardosa" in the new node and press enter
    And I select the node "Pardosa"
    And I follow "File" within "toolbar"
    And I follow "Add many nodes" within "toolbar"
    And I type the following node names into the import box:
      | Pardosa modica      |
      | Pardosa moesta      |
      | Pardosa xerampelina |
    And I press "Add children"
    And I refresh the master tree
    And I select the node "Pardosa"
    And I expand the node "Pardosa"
    Then I should see a node "Pardosa modica" under "Pardosa"
    And I should see a node "Pardosa moesta" under "Pardosa"
    And I should see a node "Pardosa xerampelina" under "Pardosa"