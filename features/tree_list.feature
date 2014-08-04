Feature: Create and manage master trees
  As a user
  I can create a new master tree, or edit an existing one
  So I can manage my classification work

  @javascript
  Scenario: User can create a new tree
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "Create Working Tree"
    Then I should be on the master tree page for "New Working Tree"
    And I should be focused on the master tree title field
    And I should see "Enter a title for your newly created tree."
    When I click on the page
    Then I should see "Please enter a title for your tree."
    And I should be focused on the master tree title field
    When I fill in "master_tree_title_input" with "My new tree"
    And I click on the page
    Then I should not see the master tree title field
    And I should see "My new tree"
    When I go to the master tree page for "My new tree"
    Then I should see "My new tree"

  Scenario: User can view a list of trees they have access to
    Given I have signed in with "email@person.com/password"
    And a user "notme@person.com/password" already exists
    Then I should be on the master tree index page

    When "notme@person.com" has created an existing master tree titled "A new tree" with:
      | hydrochaeris |
    And the following master tree contributor exists:
      | master tree      | user                   |
      | title:A new tree | email:email@person.com |
    And I go to the master trees page
    Then I should see "Trees You Can Edit"
    And I should not see "Trees You Created"
    And I should see "A new tree"

    When I follow "A new tree"
    Then I should be on the master tree page for "A new tree"

  Scenario: User can view a list of trees they created
    Given I have signed in with "email@person.com/password"
    Then I should be on the master tree index page

    When "email@person.com" has created an existing master tree titled "My new tree" with:
      | hydrochaeris |
    And I go to the master tree index page
    Then I should see "Trees You Created"
    And I should not see "Trees You Can Edit"
    And I should see "My new tree"

    When I follow "My new tree"
    Then I should be on the master tree page for "My new tree"

  Scenario: User can view a list of trees they created and a list of trees they have access to
    Given I have signed in with "email@person.com/password"
    And a user "notme@person.com/password" already exists
    Then I should be on the master tree index page

    When "notme@person.com" has created an existing master tree titled "A new tree" with:
      | peanuts |
    And "email@person.com" has created an existing master tree titled "My new tree" with:
      | walnuts |
    And the following master tree contributor exists:
      | master tree      | user                   |
      | title:A new tree | email:email@person.com |
    And I go to the master trees page
    Then I should see "Trees You Created"
    And I should see "Trees You Can Edit"
    And I should see "A new tree"
    And I should see "My new tree"

  Scenario: Tree details are displayed on the tree list
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | Title       | Created At | Updated At | Abstract                            | User                   |
      | Bananas     | 2009/06/22 | 2009/07/02 | All the types of bananas on my desk | email:email@person.com |
    When I am on the master tree index page
    Then I should see "Bananas"
    And I should see "June 22, 2009"

  Scenario: I should not see my reference trees on the tree index page
    Given I have signed in with "email@person.com/password"
    And the following master trees exist:
      | Title       | Created At | Updated At | Abstract                                | User                   |
      | Bananas     | 2009/06/22 | 2009/07/02 | All the types of bananas on my desk     | email:email@person.com |
      | Kittens     | 2009/08/18 | 2010/03/14 | All the types of kittens in my basement | email:email@person.com |
    And the following reference trees exist:
      | Title       | Created At | Updated At | Abstract                                      |
      | Cats        | 2009/08/18 | 2010/08/18 | Cats documented by a super cat expert on cats |
    And the following reference tree collection exist:
      | master tree    | reference tree |
      | title: Kittens | title: Cats    |
    When I go to the master tree index page
    Then I should see "Bananas"
    And I should see "Kittens"
    And I should not see "Cats"
