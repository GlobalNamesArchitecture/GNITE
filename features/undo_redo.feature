Feature: Perform undo and redo in a master tree
  As a user
  I can execute undo and redo in my master trees
  So that I can correct my actions

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with:
      | Pardosa             |
      | Pardosa distincta   |
      | Pardosa xerampelina |
    And I am on the master tree index page
    When I follow "Spiders"
    And I wait for the tree to load
    And I drag "Pardosa distincta" under "Pardosa"
    And I drag "Pardosa xerampelina" under "Pardosa"

  @javascript
  Scenario: User can undo and redo moving a node
    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    Then I should see a node "Pardosa xerampelina" at the root level in my master tree
    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    Then I should see a node "Pardosa xerampelina" under "Pardosa"

  @javascript
  Scenario: User can undo and redo editing a node
    When I double click "Pardosa distincta" and change it to "Pardosa moesta"
    Then I should see a node "Pardosa moesta" under "Pardosa"
    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    Then I should see a node "Pardosa distincta" under "Pardosa"
    And I should see a node "Pardosa xerampelina" under "Pardosa"
    And I should not see a node "Pardosa moesta" under "Pardosa"
    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    Then I should see a node "Pardosa moesta" under "Pardosa"
    And I should not see a node "Pardosa distincta" under "Pardosa"
    And I should see a node "Pardosa xerampelina" under "Pardosa"

  @javascript
  Scenario: User can undo and redo deleting a node
    When I delete the node "Pardosa distincta"
    And I refresh the master tree
    Then I should see a node "Pardosa xerampelina" under "Pardosa"
    And I should not see a node "Pardosa distincta" under "Pardosa"
    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    Then I should see a node "Pardosa xerampelina" under "Pardosa"
    And I should see a node "Pardosa distincta" under "Pardosa"
    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    Then I should not see a node "Pardosa distincta" under "Pardosa"
    And I should see a node "Pardosa xerampelina" under "Pardosa"

  @javascript
  Scenario: User can undo and redo copying a node from a reference tree
    When I follow "Import"
    And I import a flat list tree with the following nodes:
      | Pardosa modica   |
      | Pardosa fuscula  |
    And pause 3
    And I follow "All reference trees"
    And I follow "List"
    Then I should see a node "Pardosa modica" at the root level in my reference tree "List"
    And I should see a node "Pardosa fuscula" at the root level in my reference tree "List"
    When I drag "Pardosa fuscula" in my reference tree "List" to "Pardosa" in my master tree
    Then I should see a node "Pardosa fuscula" at the root level in my reference tree "List"
    And I should see a node "Pardosa fuscula" under "Pardosa"
    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    Then I should not see a node "Pardosa fuscula" under "Pardosa"
    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    Then I should see a node "Pardosa fuscula" under "Pardosa"


    