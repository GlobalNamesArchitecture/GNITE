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
    Then I should see a node "Lycosidae" at the root level in my master tree
    And I should see a node "Lycosidae" at the root level in my reference tree "My Reference Tree"

  @javascript
  Scenario: Improperly selecting nodes prior to executing merge throws a message
    When I go to the master tree page for "My Master Tree"
    And I wait for the tree to load
    And I follow "All reference trees (1)"
    And I follow "My Reference Tree"
    And I select the node "Lycosidae"
    And I follow "Tools" within "toolbar"
    And I follow "Merge" within "toolbar"
    Then I should see "Select one name in your working tree and one name in your reference tree then re-execute merge." within the dialog box
    And I press "OK"
    When I click the master tree background
    And I select the node "Lycosidae" in my reference tree
    And I follow "Merge" within "toolbar"
    Then I should see "Select one name in your working tree and one name in your reference tree then re-execute merge." within the dialog box
    And I press "OK"
    When I select the node "Lycosidae"
    And I follow "Merge" within "toolbar"
    Then I should not see "Select one name in your working tree and one name in your reference tree then re-execute merge." within the dialog box
    