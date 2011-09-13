Feature: Publish a master tree
  So that I can make my tree publicly accessible
  As a user
  I can publish a master tree I created

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Fishing Spiders" with the following nodes:
      | id   | parent_id | name                   |
      | 100  | 0         | Dolomedes              |
      | 101  | 100       | Dolomedes tenebrosus   |
      | 102  | 100       | Dolomedes albinaeus    |
      | 103  | 100       | Dolomedes fimbriatus   |
    And I go to the master tree page for "Fishing Spiders"

  @javascript
  Scenario: Cancel publishing a tree
    When I follow "File" within "toolbar"
    And I follow "Publish tree" within "toolbar"
    Then I should see "Publish Confirmation"
    When I press "Cancel"
    Then I should not see "Publish Confirmation"

  @javascript
  Scenario: Publish a tree
    When I go to the master tree page for "Fishing Spiders"
    And I follow "File" within "toolbar"
    And I follow "Publish tree" within "toolbar"
    Then I should see "Publish Confirmation"

    When I press "Publish"
    And pause 1
    Then I should see "Publishing in Progress"