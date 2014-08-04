Feature: Search within trees
  As a user
  I can type a name in the search box above trees
  So that I can quickly navigate to a name

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with the following nodes:
      | id   | parent_id | name                |
      | 100  | 0         | Pardosa             |
      | 101  | 100       | Pardosa distincta   |
    And I am on the master tree index page
    When I follow "Spiders"
    And I wait for the tree to load

  @javascript
  Scenario: User can search for a name in the master tree
    When I search for "Pardosa distincta" in the master tree search box
    Then I should see "Pardosa >" in the master tree search results
    Then I should see "Pardosa distincta" in the master tree search results

  @javascript
  Scenario: User gets a nothing found message when searching for a non-existent name in the master tree
    When I search for "Pardosa xerampelina" in the master tree search box
    Then I should see "Nothing found" in the master tree search results when nothing is found

  @javascript
  Scenario: User can click a name in the search results and the searched name is highlighted
    When I search for "Pardosa distincta" in the master tree search box
    And I follow "Pardosa > Pardosa distincta"
    Then I should see a node "Pardosa distincta" under "Pardosa"
    And the "Pardosa distincta" tree node should be selected 
    