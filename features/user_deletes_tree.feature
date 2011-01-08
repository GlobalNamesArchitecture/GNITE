Feature: Delete a master tree
  So that I can clean up my tree list
  As a user
  I can delete a master tree

  Scenario: Delete a tree
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | user                    | title       |
      | email: email@person.com | My new tree |
      | email: email@person.com | Delete me   |
    And the following deleted tree exists:
      | user | master_tree |
      | email: email@person.com | title: My new tree |
    And the following deleted tree exists:
      | user | master_tree |
      | email: email@person.com | title: Delete me |
    When I go to the master tree page for "Delete me"
    And I press "Delete Tree"
    Then I should be on the master tree index page
    And I should see "Tree successfully deleted"
    And I should not see "Delete me"
    But I should see "My new tree"
