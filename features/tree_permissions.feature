Feature: Contributor can edit nodes but cannot manage a tree that he/she contributes to
  As a user
  I can contribute to someone else's master tree when I have permission
  But I cannot delete, publish, or adjust its metadata
  So that the owner is assured that only he/she can do so

  @javascript
  Scenario: User can see nodes on a master tree that he/she contributes to
    Given I have signed in with "email@person.com/password"
    And a user "email2@person.com/password" already exists
    And "email2@person.com" has created an existing master tree titled "Waterpigs" with:
      | hydrochaeris |
    And "email@person.com" is a contributor to the master tree "Waterpigs"
    When I go to the master tree index page
    And I follow "Waterpigs"
    And I wait for the tree to load
    Then I should see a node "hydrochaeris" at the root level in my master tree

  @javascript
  Scenario: User can add nodes to a master tree that he/she contributes to
    Given I have signed in with "email@person.com/password"
    And a user "email2@person.com/password" already exists
    And "email2@person.com" has created an existing master tree titled "Waterpigs" with:
      | hydrochaeris |
    And "email@person.com" is a contributor to the master tree "Waterpigs"
    When I go to the master tree page for "Waterpigs"
    And I wait for the tree to load
    And I wait for the websocket to activate
    And I follow "File" within "toolbar"
    And I follow "Add single node" within "toolbar"
    And I enter "child" in the new node and press enter
    And I wait for the tree to load
    Then I should see a node "child" at the root level in my master tree

  @javascript
  Scenario: User cannot see Edit, Delete or Publish in the menu on a master tree that he/she contributes to
    Given I have signed in with "email@person.com/password"
    And a user "email2@person.com/password" already exists
    And "email2@person.com" has created an existing master tree titled "Waterpigs" with:
      | hydrochaeris |
    And "email@person.com" is a contributor to the master tree "Waterpigs"
    When I go to the master tree index page
    And I follow "Waterpigs"
    And I wait for the tree to load
    And I follow "File" within "toolbar"
    Then I should not see "Edit tree info" within "#toolbar"
    And I should not see "Publish tree" within "#toolbar"
    And I should not see "Delete tree" within "#toolbar"