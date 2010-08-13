Feature: Import data to your master tree
  As a user
  I can import data to my master trees
  So that I don't have to manipulate everything by hand

  @javascript
  Scenario: User can import flat list as root nodes
   Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "New Master Tree"
    And I fill in "Title" with "My new tree"
    And I press "Create"
    Then I should be on the tree page for "My new tree"
    When I type the following node names into the import box:
      | root one   |
      | root two   |
      | root three |
    And I press "Import"
    Then I should see a node "root one" at the root level in my master tree
    And I should see a node "root two" at the root level in my master tree
    And I should see a node "root three" at the root level in my master tree
