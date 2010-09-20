Feature: Work with reference trees
  As a user
  I can work from reference trees
  So that I can combine multiple pieces of work

  Background: I have a reference tree
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | user                    | title       |
      | email: email@person.com | My new tree |
    And I go to the master tree page for "My new tree"
    And I follow "Add Node"
    And I enter "master node" in the new node and press enter
    And I import a flat list tree with the following nodes:
      | root one   |
      | root two   |
      | root three |

  @javascript
  Scenario: Reference trees are not editable
    Then I should not be able to show a context menu for my reference tree "List"

  @javascript
  Scenario: Drag-and-drop reordering is not possible in reference trees
    When I wait for the tree to load
    And I drag "root three" under "root two" in my reference tree "List"

    Then I should see a node "root one" at the root level in my reference tree "List"
    And I should see a node "root two" at the root level in my reference tree "List"
    And I should see a node "root three" at the root level in my reference tree "List"

    When I follow "Master Trees"
    And I follow "My new tree"
    And I follow "List"
    And I wait for the tree to load

    Then I should see a node "root one" at the root level in my reference tree "List"
    And I should see a node "root two" at the root level in my reference tree "List"
    And I should see a node "root three" at the root level in my reference tree "List"

  @javascript
  Scenario: Reference tree metadata is viewable but not editable
