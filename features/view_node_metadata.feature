Feature: View metadata for master tree nodes

  Background:
    Given I have signed in with "email@person.com/password"
    And the following master tree exists:
      | title |
      | Foods |
    And the following master tree contributor exists:
      | master tree | user                   |
      | title:Foods | email:email@person.com |
    And the following nodes exist with metadata for the "Foods" tree:
      | name | synonyms        | vernacular_names | rank    |
      | Nut  | Kernel, Nutmeat | Almond, Peanut   | Species |
      | Pop  | Soda, Softdrink | Coke, Dr. Pepper | Family  |
      | Cat  |                 |                  |         |
    And the following reference trees exist:
      | title  |
      | Snacks |
      | Fruits |
    And the following reference tree collection exist:
      | master tree  | reference tree |
      | title: Foods | title: Snacks  |
      | title: Foods | title: Fruits  |
    And the following nodes exist with metadata for the "Snacks" tree:
      | name    | synonyms | vernacular_names | rank |
      | Twinkie | Cake     | Twinkie Cake     | Good |
    And the following nodes exist with metadata for the "Fruits" tree:
      | name     | synonyms | vernacular_names | rank  |
      | Apple    | Orange   | Red Apple        | Round |
      | Cucumber |          |                  |       |
    And I go to the master tree page for "Foods"
    And I wait for the tree to load

  @javascript
  Scenario: User can view metadata for nodes on a master tree
    When I select the node "Nut"
    Then I should see "Kernel, Nutmeat" as synonyms for the "Foods" tree
    And I should see "Almond, Peanut" as vernacular names for the "Foods" tree
    And I should see "Species" as rank for the "Foods" tree
    When I select the node "Pop"
    Then I should not see a spinner
    And I should see "Soda, Softdrink" as synonyms for the "Foods" tree
    And I should see "Coke, Dr. Pepper" as vernacular names for the "Foods" tree
    And I should see "Family" as rank for the "Foods" tree
    When I select the node "Cat"
    Then I should see "None" as synonyms for the "Foods" tree
    And I should see "None" as vernacular names for the "Foods" tree
    And I should see "None" as rank for the "Foods" tree

  @javascript
  Scenario: User can view metadata for nodes on reference trees
    When I follow "All reference trees"
    And I follow "Snacks"
    And I select the node "Twinkie"
    Then I should see "Cake" as synonyms for the "Snacks" tree
    And I should see "Twinkie Cake" as vernacular names for the "Snacks" tree
    And I should see "Good" as rank for the "Snacks" tree
    When I follow "All reference trees"
    And I follow "Fruits"
    And I select the node "Apple"
    Then I should see "Orange" as synonyms for the "Fruits" tree
    And I should see "Red Apple" as vernacular names for the "Fruits" tree
    And I should see "Round" as rank for the "Fruits" tree
    When I select the node "Cucumber"
    Then I should see "None" as synonyms for the "Fruits" tree
    And I should see "None" as vernacular names for the "Fruits" tree
    And I should see "None" as rank for the "Fruits" tree

  @javascript
  Scenario: User can edit a synonym in the metadata panel
    When I select the node "Nut"
    Then I should see "Kernel, Nutmeat" as synonyms for the "Foods" tree
    When I rename the synonym "Kernel" to "Walnut"
    And I select the node "Nut"
    Then I should see "Walnut, Nutmeat" as synonyms for the "Foods" tree

  @javascript
  Scenario: User can edit the rank of a node in the metadata panel
    When I select the node "Nut"
    Then I should see "Species" as rank for the "Foods" tree
    When I edit the rank to "subspecies"
    And I select the node "Nut"
    Then I should see "subspecies" as rank for the "Foods" tree

  @javascript
  Scenario: User can change the synonym designation in the metadata panel
    When I select the node "Nut"
    And I follow "Kernel" within "the master tree metadata panel"
    And I follow "homotypic synonym" within "the master tree metadata panel"
    And I select the node "Nut"
    And I follow "Kernel" within "the master tree metadata panel"
    Then the synonym "Kernel" should be of type "homotypic synonym"

  @javascript
  Scenario: User can add a new synonym in the metadata panel
    When I select the node "Nut"
    And I add a new synonym "Macadamia"
    And I select the node "Nut"
    Then I should see "Kernel, Nutmeat, Macadamia" as synonyms for the "Foods" tree

  @javascript
  Scenario: User can add a new vernacular in the metadata panel
    When I select the node "Nut"
    And I add a new vernacular "Cashew"
    And I select the node "Nut"
    Then I should see "Almond, Peanut, Cashew" as vernacular names for the "Foods" tree

  @javascript
  Scenario: User can change the language for a vernacular in the metadata panel
    When I select the node "Nut"
    And I follow "Almond" within "the master tree metadata panel"
    And I change the language to "French"
    And I select the node "Nut"
    And I follow "Almond" within "the master tree metadata panel"
    Then I should see "French" as the vernacular language for "Almond"

  @javascript
  Scenario: User can delete a synonym in the metadata panel
    When I select the node "Nut"
    And I right-click the synonym "Kernel"
    And I follow "Delete" within "the metadata panel context menu"
    And I select the node "Nut"
    Then I should see "Nutmeat" as synonyms for the "Foods" tree
    And I should not see "Kernel" as synonyms for the "Foods" tree

  @javascript
  Scenario: User can delete a vernacular in the metadata panel
    When I select the node "Nut"
    And I right-click the vernacular name "Peanut"
    And I follow "Delete" within "the metadata panel context menu"
    And I select the node "Nut"
    Then I should see "Almond" as vernacular names for the "Foods" tree
    And I should not see "Peanut" as vernacular names for the "Foods" tree
