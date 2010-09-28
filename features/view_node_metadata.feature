Feature: View metadata for master tree nodes

  @javascript
  Scenario: User can view metadata for nodes on a master tree
    Given I have signed in with "email@person.com/password"
    And the following tree exists:
      | user                    | title |
      | email: email@person.com | Foods |
    And the following nodes exist with metadata for the "Foods" tree:
      | name | synonyms        | vernacular_names | rank    |
      | Nut  | Kernel, Nutmeat | Almond, Peanut   | Species |
      | Pop  | Soda, Softdrink | Coke, Dr. Pepper | Family  |
    And I go to the master tree page for "Foods"
    And I wait for the tree to load
    When I select the node "Nut"
    Then I should see "Kernel, Nutmeat" as synonyms
    And I should see "Almond, Peanut" as vernacular names
    And I should see "Species" as rank
    When I select the node "Pop"
    Then I should see "Soda, Softdrink" as synonyms
    And I should see "Coke, Dr. Pepper" as vernacular names
    And I should see "Family" as rank
