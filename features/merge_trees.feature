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
  Scenario: Viewing the merge events list page should not yet have any entries
    When I go to the master tree page for "My Master Tree"
    And I follow "View" within "toolbar"
    And I follow "Merge events" within "toolbar"
    Then I should be on the merge events page for "My Master Tree"
    And I should see "There are not yet any merge events"

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
    And I follow "Tools" within "toolbar"
    And I follow "Merge" within "toolbar"
    Then I should see "Select one name in your working tree and one name in your reference tree then re-execute merge." within the dialog box
    And I press "OK"
    When I expand the node "Lycosidae" in my reference tree "My Reference Tree"
    And I wait for the reference tree to load
    And I select the node "Pardosa" in my reference tree
    And I follow "Tools" within "toolbar"
    And I follow "Merge" within "toolbar"
    Then I should see "Select one name in your working tree and one name in your reference tree then re-execute merge." within the dialog box
    And I press "OK"
    When I select the node "Pardosa" in my reference tree
    And I select the node "Lycosidae"
    And I follow "Tools" within "toolbar"
    And I follow "Merge" within "toolbar"
    Then I should see "Lycosidae" within the dialog box
    And I should not see "Pardosa" within the dialog box
    And I should see "Lycosidae" within "#master-tree-merge-selection"
    And I should see "Lycosidae" within "#reference-tree-merge-selection"

  @javascript
  Scenario: Executing merge by selecting one authoritative node produces a spinner then a view button
    When I go to the master tree page for "My Master Tree"
    And I wait for the tree to load
    And I follow "All reference trees (1)"
    And I follow "My Reference Tree"
    And I wait for the reference tree to load
    And I select the node "Lycosidae"
    And I select the node "Lycosidae" in my reference tree
    And I follow "Tools" within "toolbar"
    And I follow "Merge" within "toolbar"
    And I choose "Lycosidae" within "#reference-tree-merge-selection"
    And I press "Merge"
    Then I should see "Starting merge..."
    And I should see a spinner

    When merge jobs are run
    And I wait for the merge to complete
    Then the master tree should be locked

    When I follow "View" within the dialog box
    Then I should be on the merge results page for "My Master Tree"

  @javascript
  Scenario: Executing merge by selecting the other authoritative node produces a spinner then a view button
    When I go to the master tree page for "My Master Tree"
    And I wait for the tree to load
    And I follow "All reference trees (1)"
    And I follow "My Reference Tree"
    And I wait for the reference tree to load
    And I select the node "Lycosidae"
    And I select the node "Lycosidae" in my reference tree
    And I follow "Tools" within "toolbar"
    And I follow "Merge" within "toolbar"
    And I choose "Lycosidae" within "#reference-tree-merge-selection" 
    And I press "Merge"
    Then I should see "Starting merge..."
    And I should see a spinner

    When merge jobs are run
    And I wait for the merge to complete
    Then the master tree should be locked

    When I follow "View" within the dialog box
    Then I should be on the merge results page for "My Master Tree"
    
