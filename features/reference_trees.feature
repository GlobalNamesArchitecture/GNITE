Feature: Work with reference trees
  As a user
  I can work from reference trees
  So that I can combine multiple pieces of work

  Background: I have a reference tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with the following nodes:
      | id   | parent_id | name                |
      | 100  | 0         | Pardosa             |
    And I go to the master tree page for "Spiders"
    And I import a flat list tree with the following nodes:
      | Pardosa distincta   |
      | Pardosa moesta      |
      | Pardosa xerampelina |
    And pause 3
    And I follow "All reference trees"
    And I follow "List"

  @javascript
  Scenario: Reference trees are not editable
    Then I should not be able to show a context menu for my reference tree "List"

  @javascript
  Scenario: Drag-and-drop reordering is not possible in reference trees
    And I drag "Pardosa moesta" to "Pardosa distincta" in my reference tree "List"

    Then I should see a node "Pardosa distincta" at the root level in my reference tree "List"
    And I should see a node "Pardosa moesta" at the root level in my reference tree "List"
    And I should see a node "Pardosa xerampelina" at the root level in my reference tree "List"

    When I follow "Working Trees"
    And I follow "Spiders"
    And I wait for the tree to load
    And I follow "All reference trees"
    And I follow "List"

    Then I should see a node "Pardosa distincta" at the root level in my reference tree "List"
    And I should see a node "Pardosa moesta" at the root level in my reference tree "List"
    And I should see a node "Pardosa xerampelina" at the root level in my reference tree "List"

  @javascript
  Scenario: Drag-and-drop copying from reference tree to master tree
    And I drag "Pardosa xerampelina" in my reference tree "List" to "Pardosa" in my master tree
    And I wait for the tree to load
    Then I should see a node "Pardosa xerampelina" at the root level in my reference tree "List"
    And I should see a node "Pardosa xerampelina" under "Pardosa"

    When I refresh the master tree
    And I select the node "Pardosa"
    And I expand the node "Pardosa"
    Then I should see a node "Pardosa xerampelina" under "Pardosa"
