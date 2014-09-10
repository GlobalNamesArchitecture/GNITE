Feature: Perform undo and redo in a master tree
  As a user
  I can execute undo and redo in my master trees
  So that I can correct my actions

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with the following nodes:
      | id   | parent_id | name                | rank    | synonyms                            |
      | 100  | 0         | Pardosa             | genus   |                                     |
      | 101  | 100       | Pardosa distincta   | species | Lycosa distincta, Araneus distincta |
      | 102  | 100       | Pardosa xerampelina | species | Lycosa xerampelina                  |
      | 103  | 0         | Schizocosa          | genus   |                                     |
    And I am on the master tree index page

    When I follow "Spiders"
    And I wait for the tree to load
    And I wait for the websocket to activate
    And I expand the node "Pardosa"

  @javascript
  Scenario: User can undo and redo moving a node
    When I drag "Pardosa distincta" under "Schizocosa"
    Then I should see a node "Pardosa distincta" under "Schizocosa"

    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    And I wait for the tree to load
    Then I should see a node "Pardosa distincta" under "Pardosa"
    And I should not see a node "Pardosa distincta" under "Schizocosa"
    
    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    And I wait for the tree to load
    Then I should see a node "Pardosa distincta" under "Schizocosa"
    And I should not see a node "Pardosa distincta" under "Pardosa"

  @javascript
  Scenario: User can undo and redo editing a node
    When I double click "Pardosa distincta" and change it to "Pardosa moesta"
    And I wait for the tree to load
    Then I should see a node "Pardosa moesta" under "Pardosa"

    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    And I wait for the tree to load
    Then I should see a node "Pardosa distincta" under "Pardosa"

    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    And I wait for the tree to load
    Then I should see a node "Pardosa moesta" under "Pardosa"
    And I should not see a node "Pardosa distincta" under "Pardosa"

  @javascript
  Scenario: User can undo and redo deleting a node
    When I delete the node "Pardosa distincta"
    And I wait for the tree to load
    And I refresh the master tree
    Then I should see a node "Pardosa xerampelina" under "Pardosa"
    And I should not see a node "Pardosa distincta" under "Pardosa"

    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    And I wait for the tree to load
    Then I should see a node "Pardosa xerampelina" under "Pardosa"
    And I should see a node "Pardosa distincta" under "Pardosa"

    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    And I wait for the tree to load
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
    And I wait for the tree to load
    And I should see a node "Pardosa fuscula" under "Pardosa"

    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    And I wait for the tree to load
    Then I should not see a node "Pardosa fuscula" under "Pardosa"

    When I reset the screen position
    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    And I wait for the tree to load
    Then I should see a node "Pardosa fuscula" under "Pardosa"

  @javascript
  Scenario: User can undo and redo bulk insertion
    When I select the node "Pardosa"
    And I follow "File" within "toolbar"
    And I follow "Add many nodes" within "toolbar"
    And I type the following node names into the import box:
      | Pardosa moesta  |
      | Pardosa fuscula |
    And I press "Add children"
    And I wait for the tree to load
    And I refresh the master tree
    Then I should see a node "Pardosa moesta" under "Pardosa"
    And I should see a node "Pardosa fuscula" under "Pardosa"

    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    And I wait for the tree to load
    Then I should not see a node "Pardosa moesta" under "Pardosa"
    And I should not see a node "Pardosa fuscula" under "Pardosa"

    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    And I wait for the tree to load
    Then I should see a node "Pardosa moesta" under "Pardosa"
    And I should see a node "Pardosa fuscula" under "Pardosa"

  @javascript
  Scenario: User can undo and redo bulk copy
    When I follow "Import"
    And I import a flat list tree with the following nodes:
      | Pardosa modica   |
      | Pardosa fuscula  |
    And pause 3
    And I follow "All reference trees"
    And I follow "List"
    Then I should see a node "Pardosa modica" at the root level in my reference tree "List"
    And I should see a node "Pardosa fuscula" at the root level in my reference tree "List"

    When I select the node "Pardosa modica" in my reference tree
    And I select the node "Pardosa fuscula" in my reference tree
    When I drag selected nodes in my reference tree "List" to "Pardosa" in my master tree
    And I wait for the tree to load
    Then I should see a node "Pardosa modica" under "Pardosa"
    And I should see a node "Pardosa fuscula" under "Pardosa"

    When I follow "Edit" within "toolbar"
    And I follow "Undo" within "toolbar"
    And I wait for the tree to load
    Then I should not see a node "Pardosa modica" under "Pardosa"
    And I should not see a node "Pardosa fuscula" under "Pardosa"

    When I reset the screen position
    When I follow "Edit" within "toolbar"
    And I follow "Redo" within "toolbar"
    And I wait for the tree to load
    Then I should see a node "Pardosa modica" under "Pardosa"
    And I should see a node "Pardosa fuscula" under "Pardosa"

  @javascript
  Scenario: User can undo and redo synonymizing a taxon