Feature: Import data to your master tree
  As a user
  I can import data to my master trees
  So that I don't have to manipulate everything by hand

  Background: I have a tree
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | user                    | title       |
      | email: email@person.com | My new tree |
    And I go to the master tree page for "My new tree"

  @javascript
  Scenario: User can import flat list as root nodes
    When I follow "Import"
    And I follow "Enter flat list"
    And I type the following node names into the import box:
      | root one   |
      | root two   |
      | root three |
    And I press "Import"
    Then I should see a "List" tab
    And the "List" tab should be active
    And I should see a node "root one" at the root level in my reference tree "List"
    And I should see a node "root two" at the root level in my reference tree "List"
    And I should see a node "root three" at the root level in my reference tree "List"

  @javascript
  Scenario: View breadcrumb navigation while importing a flat list
    When I follow "Import"
    And I follow "Enter flat list"
    And I follow "New Import"
    Then I should see "Enter a flat list of names to import"
    # And I should be back on the main "New Import" right-hand panel.
