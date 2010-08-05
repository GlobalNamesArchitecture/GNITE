Feature: Create and manage master trees
  As a user
  I can create a new master tree, or edit an existing one
  So I can manage my classification work

  Scenario: User can create a new tree
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "New Master Tree"
    And I fill in "Title" with "My new tree"
    And I press "Create"
    Then I should see "Tree successfully created"
    And I should be on the tree page for "My new tree"

  Scenario: User can view their list of trees
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    And I should not see "Or choose an existing tree to edit"

    When I follow "New Master Tree"
    And I fill in "Title" with "My new tree"
    And I press "Create"
    And I go to the trees page
    Then should see "My new tree"

    When I follow "My new tree"
    Then I should be on the tree page for "My new tree"
