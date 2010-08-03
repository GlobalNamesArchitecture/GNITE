Feature: Edit a master tree
  As a user
  I can edit my master trees
  So that I can create and curate classifications

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
    When I follow "Master Trees"
    Then I should be on the master tree index page
    When I follow "My new tree"
    Then I should see "hydrochaeris"

  @wip @javascript
  Scenario: User can add child nodes to a tree
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "New Tree"
    And I fill in "Title" with "My new tree"
    And I press "Create"
    When I follow "New Node"
    And I enter "Caviidae" in the new node and press enter
    Then I should see a node "Caviidae" at the root level in my master tree

    When I select the node "Caviidae"
    And I follow "New Node"
    And I enter "Hydrochoerinae" in the new node and press enter
    Then I should see "Hydrochoerinae"
    And I should see "Caviidae"
    And I should see a node "Hydrochoerinae" under "Caviidae"

    When I follow "Master Trees"
    And I follow "My new tree"
    And I expand the node "Caviidae"
    Then I should see "Hydrochoerinae"
    And I should see "Caviidae"
    And I should see a node "Hydrochoerinae" under "Caviidae"

  @javascript
  Scenario: User can rename nodes in a tree
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing tree titled "Moose tree" with:
      | Bullwinkle |
      | Rocky      |
    And I sign in as "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "Moose tree"
    And I wait for the tree to load
    And I double click "Bullwinkle" and change it to "Monkey"
    Then I should see "Monkey"
    When I follow "Master Trees"
    Then I should not see "Monkey"
    When I follow "Moose tree"
    Then I should see "Monkey"
    And I should see "Rocky"
