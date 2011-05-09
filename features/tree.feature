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
    And I wait for the tree to load
    Then I should see a node "hydrochaeris" at the root level in my master tree

  @javascript
  Scenario: User can add nodes to a tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Waterpigs" with:
      | hydrochaeris |
    When I go to the master tree page for "Waterpigs"
    And I wait for the tree to load
    And I follow "File" within "toolbar"
    And I follow "Add single node" within "toolbar"
    And I enter "child" in the new node and press enter
    And I wait for the tree to load
    Then I should see a node "child" at the root level in my master tree

  @javascript
  Scenario: User can add child nodes to a tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with the following nodes:
      | id   | parent_id | name                |
      | 100  | 0         | Pardosa             |
    When I go to the master tree page for "Spiders"
    And I wait for the tree to load
    And I select the node "Pardosa"
    And I follow "File" within "toolbar"
    And I follow "Add single node" within "toolbar"
    And I enter "Pardosa moesta" in the new node and press enter
    And I wait for the tree to load
    And I refresh the master tree
    Then I should see "Pardosa"
    And I expand the node "Pardosa"
    Then I should see a node "Pardosa moesta" under "Pardosa"

  @javascript
  Scenario: User can rename nodes in a tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
      | Rocky      |
    And I am on the master tree index page
    When I follow "Moose tree"
    And I wait for the tree to load
    And I double click "Bullwinkle" and change it to "Monkey"
    And I wait for the tree to load
    And I refresh the master tree
    Then I should see "Monkey"
    And I should see "Rocky"
    And I should not see "Bullwinkle"

   @javascript
   Scenario: User can drag a node and drop it onto another within the master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
      | Rocky      |
      | Natasha    |
      | Boris      |
    And I am on the master tree index page
    When I follow "Moose tree"
    And I wait for the tree to load
    And I drag "Rocky" under "Bullwinkle"
    And I wait for the tree to load
    Then I should see a node "Rocky" under "Bullwinkle"
    And I refresh the master tree
    When I select the node "Bullwinkle"
    And I expand the node "Bullwinkle"
    Then I should see a node "Rocky" under "Bullwinkle"

  @javascript
  Scenario: User can remove nodes in a tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
      | Rocky      |
      | Natasha    |
      | Boris      |
    And I am on the master tree index page
    When I follow "Moose tree"
    And I wait for the tree to load
    And I should see a node "Boris" at the root level in my master tree
    And I follow "Deleted Names"
    And I delete the node "Boris"
    And I wait for the tree to load
    Then I should not see a node "Boris" at the root level in my master tree
    And I should see a node "Boris" at the root level in deleted names
    And I refresh the master tree
    And I follow "View" within "toolbar-deleted"
    And I follow "Refresh tree" within "toolbar-deleted"
    And pause 2
    Then I should not see a node "Boris" at the root level in my master tree
    And I should see a node "Boris" at the root level in deleted names

  @javascript
  Scenario: User can automatically remove children nodes by deleting a parent in a tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
      | Rocky      |
      | Natasha    |
      | Boris      |
    And I am on the master tree index page
    When I follow "Moose tree"
    And I wait for the tree to load
    And I follow "Deleted Names"
    And I drag "Rocky" under "Bullwinkle"
    And I wait for the tree to load
    And I refresh the master tree
    And I delete the node "Bullwinkle"
    And I wait for the tree to load
    And I refresh the master tree
    And I follow "View" within "toolbar-deleted"
    And I follow "Refresh tree" within "toolbar-deleted"
    And pause 1
    Then I should not see a node "Bullwinkle" at the root level in my master tree
    And I should not see a node "Rocky" at the root level in my master tree
    And I should see a node "Bullwinkle" at the root level in deleted names
    And I expand the node "Bullwinkle" in deleted names
    Then I should see a node "Rocky" under "Bullwinkle" in deleted names

  @javascript
  Scenario: User can deselect a node
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And I am on the master tree index page
    When I follow "Moose tree"
    And I select the node "Bullwinkle"
    When I click the master tree background
    Then no nodes should be selected in the master tree

    When I select the node "Bullwinkle"
    And I click a non-text area of a node in the master tree
    Then no nodes should be selected in the master tree

  Scenario: User can edit the metadata for a tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And I am on the master tree index page
    When I follow "Moose tree"
    And I follow "Edit tree info"
    Then I should be on the edit master tree page for "Moose tree"
    When I fill in "Title" with "Bullwinkle tree"
    And I select "Public domain" from "License"
    And I press "Update"
    And I go to the master tree index page
    Then I should see "Bullwinkle tree"
    And I should not see "Moose tree"

  Scenario: User can cancel editing the metadata for a tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And I am on the master tree index page
    When I follow "Moose tree"
    And I follow "Edit tree info"
    Then I should be on the edit master tree page for "Moose tree"
    When I press "Cancel"
    Then I should be on the master tree page for "Moose tree"

  @javascript
  Scenario: User can cut a node and paste it under another
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Snacks" with:
      | Get Cut    |
      | Paste Here |
    And I am on the master tree index page
    When I follow "Snacks"
    And I wait for the tree to load
    And I select the node "Get Cut"
    And I click "Cut" in the context menu
    And I select the node "Paste Here"
    And I click "Paste" in the context menu
    And I wait for the tree to load
    And I refresh the master tree
    And I select the node "Paste Here"
    And I expand the node "Paste Here"
    Then I should see a node "Get Cut" under "Paste Here"
    And I should not see a node "Get Cut" at the root level in my master tree

  @javascript
  Scenario: User can add nodes from the context menu
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Snacks" with:
      | chocolate |
    And I am on the master tree index page
    When I follow "Snacks"
    And I wait for the tree to load
    And I select the node "chocolate"
    And I click "New child" in the context menu
    And I enter "cookie" in the new node and press enter
    And I wait for the tree to load
    And I refresh the master tree
    And I wait for the tree to load
    When I select the node "chocolate"
    And I expand the node "chocolate"
    Then I should see 1 child node for the "chocolate" node in my master tree