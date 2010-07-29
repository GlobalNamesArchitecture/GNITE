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
