Feature: Merge nodes between trees
  So that I can better combine trees
  As a user
  I can merge a node in my master tree with a node in my reference tree

  Background: I have a master tree and a reference tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created a master tree "My Master Tree" and a reference tree "My Reference Tree"

  @javascript
  Scenario: List a master tree
    When I am on the master tree index page
    Then I should see "My Master Tree"
    And I should not see "My Reference Tree"

  @javascript
  Scenario: View a master tree and a reference tree
    When I go to the master tree page for "My Master Tree"
    Then I should see "All reference trees (1)"
    When I follow "All reference trees (1)"
    And I follow "My Reference Tree"
    And I wait for the tree to load
    And I wait for the websocket to activate
    Then I should see a node "Lycosidae" at the root level in my master tree
    And I should see a node "Lycosidae" at the root level in my reference tree "My Reference Tree"
    