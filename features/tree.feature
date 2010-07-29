Feature: Create and Edit the Master Tree
  A user should be able to create a new tree
  A user should be able to add, delete, and edit nodes in a tree

  Scenario: User can create a new tree
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "New Tree"
    And I fill in "Title" with "My new tree"
    And I press "Create"
    Then I should be on the tree page for "My new tree"
    And I should see "Tree successfully created"

  @javascript
  Scenario: User can see nodes on an existing tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing tree titled "Waterpigs" with:
      | hydrochaeris |
    When I go to the trees page
    And I follow "Waterpigs"
    Then I should see a node "hydrochaeris" at the root level in my master tree

  @javascript
  Scenario: User can add nodes to a tree
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "New Tree"
    And I fill in "Title" with "My new tree"
    And I press "Create"

    When I follow "New Node"
    And I enter "hydrochaeris" in the new node and press enter

    Then I should see a node "hydrochaeris" at the root level in my master tree
