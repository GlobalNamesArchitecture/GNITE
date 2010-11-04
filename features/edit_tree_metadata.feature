Feature: Edit the metadata for a master tree

  Scenario: User can edit the metadata for a tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And I am on the master tree index page
    When I follow "Moose tree"
    And I follow "Edit Tree Info"
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
    And I follow "Edit Tree Info"
    Then I should be on the edit master tree page for "Moose tree"
    When I follow "Cancel"
    Then I should be on the master tree page for "Moose tree"

  @wip
  @javascript
  Scenario: Editing the metadata for a master tree should not change node structure
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
      | Rocky      |
      | Natasha    |
      | Boris      |
    And I am on the master tree index page
    When I follow "Moose tree"
    And I drag "Rocky" under "Bullwinkle"
    Then I should see a node "Rocky" under "Bullwinkle"
    When I follow "Edit Tree Info"
    And I fill in "Title" with "New and improved title"
    And I press "Update"
    Then I should see "New and improved title"
    And I expand the node "Bullwinkle"
    And I should see a node "Rocky" under "Bullwinkle"
    When pause 5
