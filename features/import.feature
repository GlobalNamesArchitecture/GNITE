Feature: Import data to your master tree
  As a user
  I can import data to my master trees
  So that I don't have to manipulate everything by hand

  Background: I have a tree
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | title       |
      | My new tree |
    And the following master tree contributor exists:
      | master tree       | user                   |
      | title:My new tree | email:email@person.com |
    And I go to the master tree page for "My new tree"

  @javascript
  Scenario: User can import flat list as root nodes
    Then I should not see the reference trees tab
    When I follow "Import"
    And I follow "Enter Flat List"
    And I fill in "Title" with "My Sweet List"
    And I type the following node names into the import box:
      | root one   |
      | root two   |
      | root three |
    And I press "Import"
    Then I should see a "My Sweet List" tab
    And I should see "All reference trees (1)"
    And I should see the breadcrumb path "My Sweet List"
    And I should see a node "root one" at the root level in my reference tree "My Sweet List"
    And I should see a node "root two" at the root level in my reference tree "My Sweet List"
    And I should see a node "root three" at the root level in my reference tree "My Sweet List"

  @javascript
  Scenario: User attempting to import an invalid flat list
    When I follow "Import"
    And I follow "Enter Flat List"
    And I press "Import"
    Then I should see "Title is required"
    And I should see "List of Taxa is required"
    And I should not see the reference trees tab

  @javascript
  Scenario: View breadcrumb navigation while importing a flat list
    When I follow "Import"
    And I follow "Enter Flat List"
    And I follow "New Import"
    Then I should see "Enter a flat list to import"
    # And I should be back on the main "New Import" right-hand panel.
