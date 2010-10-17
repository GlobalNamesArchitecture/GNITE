Feature: Create and manage master trees
  As a user
  I can create a new master tree, or edit an existing one
  So I can manage my classification work

  @javascript
  Scenario: User can create a new tree
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "New Master Tree"
    Then I should be on the master tree page for "New Master Tree"
    And I should see "Enter a title for your newly created tree."
    And I should be focused on the master tree title field
    When I click on the page
    Then I should see "Please enter a title for your tree."
    And I should be focused on the master tree title field
    When I fill in "master_tree_title" with "My new tree"
    And I click on the page
    Then I should not see the master tree title field
    And I should see "My new tree"
    When I go to the master tree page for "My new tree"
    Then I should see "My new tree"

  Scenario: User can view their list of trees
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    And I should not see "Or choose an existing tree to edit"

    When the following master tree exists:
      | user                    | title       |
      | email: email@person.com | My new tree |
    And I go to the master trees page
    Then should see "My new tree"

    When I follow "My new tree"
    Then I should be on the master tree page for "My new tree"

  Scenario: Tree details are displayed on the tree list
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | Title       | Created At | Updated At | Abstract                            | User                    |
      | Bananas     | 2009/06/22 | 2009/07/02 | All the types of bananas on my desk | Email: email@person.com |
    When I am on the master tree index page
    Then I should see "Bananas"
    And I should see "2009/06/22"
    And I should see "2009/07/02"
    And I should see "All the types of bananas on my desk"

  Scenario: I should not see my reference trees on the tree index page
    Given I have signed in with "email@person.com/password"
    And the following master trees exist:
      | Title       | Created At | Updated At | Abstract                                | User                    |
      | Bananas     | 2009/06/22 | 2009/07/02 | All the types of bananas on my desk     | Email: email@person.com |
      | Kittens     | 2009/08/18 | 2010/03/14 | All the types of kittens in my basement | Email: email@person.com |
    And the following reference trees exist:
      | Title       | Created At | Updated At | Abstract                                      | User                    |
      | Cats        | 2009/08/18 | 2010/08/18 | Cats documented by a super cat expert on cats | Email: email@person.com |
    When I go to the master tree index page
    Then I should see "Bananas"
    And I should see "Kittens"
    And I should not see "Cats"
