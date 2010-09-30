Feature: View metadata for master tree nodes

  Background:
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | user                    | title |
      | email: email@person.com | Foods |
    And the following nodes exist with metadata for the "Foods" tree:
      | name | synonyms        | vernacular_names | rank    |
      | Nut  | Kernel, Nutmeat | Almond, Peanut   | Species |
      | Pop  | Soda, Softdrink | Coke, Dr. Pepper | Family  |
    And the following reference trees exist:
      | user                    | master_tree  | title  |
      | email: email@person.com | title: Foods | Snacks |
      | email: email@person.com | title: Foods | Fruits |
    And the following nodes exist with metadata for the "Snacks" tree:
      | name    | synonyms | vernacular_names | rank |
      | Twinkie | Cake     | Twinkie Cake     | Good |
    And the following nodes exist with metadata for the "Fruits" tree:
      | name  | synonyms | vernacular_names | rank  |
      | Apple | Orange   | Red Apple        | Round |
    And I go to the master tree page for "Foods"
    And I wait for the tree to load

  @javascript
  Scenario: User can view metadata for nodes on a master tree
    When I select the node "Nut"
    Then I should see "Kernel, Nutmeat" as synonyms for the "Foods" tree
    And I should see "Almond, Peanut" as vernacular names for the "Foods" tree
    And I should see "Species" as rank for the "Foods" tree
    When I select the node "Pop"
    Then I should see a spinner
    When pause 1
    Then I should not see a spinner
    And I should see "Soda, Softdrink" as synonyms for the "Foods" tree
    And I should see "Coke, Dr. Pepper" as vernacular names for the "Foods" tree
    And I should see "Family" as rank for the "Foods" tree

  @javascript
  Scenario: User can view metadata for nodes on reference trees
    When I follow "All working trees"
    And I follow "Snacks"
    And I select the node "Twinkie"
    Then I should see a spinner
    When pause 1
    Then I should not see a spinner
    And I should see "Cake" as synonyms for the "Snacks" tree
    And I should see "Twinkie Cake" as vernacular names for the "Snacks" tree
    And I should see "Good" as rank for the "Snacks" tree
    When I follow "All working trees"
    And I follow "Fruits"
    And I select the node "Apple"
    Then I should see a spinner
    When pause 1
    Then I should not see a spinner
    And I should see "Orange" as synonyms for the "Fruits" tree
    And I should see "Red Apple" as vernacular names for the "Fruits" tree
    And I should see "Round" as rank for the "Fruits" tree
