Feature: Edit a master tree
  As a user
  I can edit my master trees
  So that I can create and curate classifications

  @javascript
  Scenario: User can see nodes on an existing master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Waterpigs" with:
      | hydrochaeris |
    When I go to the master tree index page
    And I follow "Waterpigs"
    Then I should see a node "hydrochaeris" at the root level in my master tree

  @javascript
  Scenario: User can add nodes to a tree
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "New Master Tree"
    And I fill in "Title" with "My new tree"
    And I press "Create"
    When I follow "Add Node"
    And I enter "hydrochaeris" in the new node and press enter
    Then I should see a node "hydrochaeris" at the root level in my master tree
    When I follow "Master Trees"
    Then I should be on the master tree index page
    When I follow "My new tree"
    Then I should see "hydrochaeris"

  @javascript
  Scenario: User can add child nodes to a tree
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "New Master Tree"
    And I fill in "Title" with "My new tree"
    And I press "Create"
    When I follow "Add Node"
    And I enter "Caviidae" in the new node and press enter
    Then I should see a node "Caviidae" at the root level in my master tree

    When I select the node "Caviidae"
    And I follow "Add Node"
    And I enter "Hydrochoerinae" in the new node and press enter
    Then I should see "Hydrochoerinae"
    And I should see "Caviidae"
    And I should see a node "Hydrochoerinae" under "Caviidae"

    When I follow "Master Trees"
    And I follow "My new tree"
    And I wait for the tree to load
    When I select the node "Caviidae"
    And I expand the node "Caviidae"
    Then I should see "Hydrochoerinae"
    And I should see "Caviidae"
    And I should see a node "Hydrochoerinae" under "Caviidae"

  @javascript
  Scenario: User can rename nodes in a tree
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
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

   @javascript
   Scenario: User can move nodes in a tree
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
      | Rocky      |
      | Natasha    |
      | Boris      |
    And I sign in as "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "Moose tree"
    And I wait for the tree to load
    And I drag "Rocky" under "Bullwinkle"
    Then I should see a node "Rocky" under "Bullwinkle"

    When I follow "Master Trees"
    And I follow "Moose tree"
    And I wait for the tree to load
    When I select the node "Bullwinkle"
    And I expand the node "Bullwinkle"
    Then I should see a node "Rocky" under "Bullwinkle"

    When I follow "Master Trees"
    And I follow "Moose tree"
    And I drag "Bullwinkle" under "Natasha"
    Then I should see a node "Bullwinkle" under "Natasha"

  @javascript
  Scenario: User can remove nodes in a tree
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
      | Rocky      |
      | Natasha    |
      | Boris      |
    And I sign in as "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "Moose tree"
    And I wait for the tree to load
    And I should see a node "Boris" at the root level in my master tree
    And I delete the node "Boris"
    Then I should not see a node "Boris" at the root level in my master tree
    When I follow "Master Trees"
    And I follow "Moose tree"
    Then I should not see a node "Boris" at the root level in my master tree

  @javascript
  Scenario: User can automatically remove children nodes by deleting a parent in a tree
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
      | Rocky      |
      | Natasha    |
      | Boris      |
    And I sign in as "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "Moose tree"
    And I drag "Rocky" under "Bullwinkle"
    And I delete the node "Bullwinkle"
    Then I should not see a node "Bullwinkle" at the root level in my master tree
    And I should not see a node "Rocky" at the root level in my master tree
    When I follow "Master Trees"
    And I follow "Moose tree"
    Then I should not see a node "Bullwinkle" at the root level in my master tree
    And I should not see a node "Rocky" at the root level in my master tree

  @javascript
  Scenario: User can deselect a node
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And I sign in as "email@person.com/password"
    When I follow "Moose tree"
    And I select the node "Bullwinkle"
    When I click the master tree background
    Then no nodes should be selected in the master tree

    When I select the node "Bullwinkle"
    And I click a non-text area of a node in the master tree
    Then no nodes should be selected in the master tree

  Scenario: User can edit the metadata for a tree
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And I sign in as "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "Moose tree"
    And I follow "Edit Tree Information"
    Then I should be on the edit master tree page for "Moose tree"
    When I fill in "Title" with "Bullwinkle tree"
    And I select "Public domain" from "License"
    And I press "Update"
    And I go to the master tree index page
    Then I should see "Bullwinkle tree"
    And I should not see "Moose tree"

  Scenario: User can cancel editing the metadata for a tree
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And I sign in as "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "Moose tree"
    And I follow "Edit Tree Information"
    Then I should be on the edit master tree page for "Moose tree"
    When I follow "Cancel"
    Then I should be on the master tree page for "Moose tree"


  @javascript
  Scenario: User can cut and paste a node
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Snacks" with:
      | Get Cut    |
      | Paste Here |
    And I sign in as "email@person.com/password"
    When I follow "Snacks"

    And I wait for the tree to load
    And I select the node "Get Cut"
    And I click "Cut" in the context menu
    And I select the node "Paste Here"
    And I click "Paste" in the context menu

    When I reload the page
    And I wait for the tree to load
    And I expand the node "Paste Here"
    Then I should see a node "Get Cut" under "Paste Here"
    And I should not see a node "Get Cut" at the root level in my master tree
