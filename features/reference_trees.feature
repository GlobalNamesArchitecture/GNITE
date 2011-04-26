Feature: Work with reference trees
  As a user
  I can work from reference trees
  So that I can combine multiple pieces of work

  Background: I have a reference tree
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | title       |
      | My new tree |
    And the following master tree contributor exists:
      | master_tree        | user                   |
      | title: My new tree | email:email@person.com |
    And I go to the master tree page for "My new tree"
    And I follow "File" within "toolbar"
    And follow "Add single node" within "toolbar"
    And I enter "master node" in the new node and press enter
    And I import a flat list tree with the following nodes:
      | root one   |
      | root two   |
      | root three |
    And pause 3
    And I follow "All reference trees"
    And I follow "List"

  @javascript
  Scenario: Reference trees are not editable
    Then I should not be able to show a context menu for my reference tree "List"

  @javascript
  Scenario: Drag-and-drop reordering is not possible in reference trees
    And I drag "root three" to "root two" in my reference tree "List"

    Then I should see a node "root one" at the root level in my reference tree "List"
    And I should see a node "root two" at the root level in my reference tree "List"
    And I should see a node "root three" at the root level in my reference tree "List"

    When I follow "Working Trees"
    And I follow "My new tree"
    And I follow "All reference trees"
    And I follow "List"
    And I wait for the tree to load

    Then I should see a node "root one" at the root level in my reference tree "List"
    And I should see a node "root two" at the root level in my reference tree "List"
    And I should see a node "root three" at the root level in my reference tree "List"

  @javascript
  Scenario: Drag-and-drop copying from reference tree to master tree
    And I drag "root three" in my reference tree "List" to "master node" in my master tree
    Then I should see a node "root three" at the root level in my reference tree "List"
    And I should see a node "root three" under "master node"

    When I follow "Working Trees"
    And I follow "My new tree"
    And I follow "All reference trees"
    And I follow "List"
    And I wait for the tree to load
    When I select the node "master node"
    And I expand the node "master node"

    Then I should see a node "root three" under "master node"
    And I should see a node "root three" at the root level in my reference tree "List" 

  @javascript
  Scenario: Reference tree metadata is viewable but not editable
