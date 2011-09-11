Feature: Chat
  As a user
  I can chat with colleagues
  So that I can quickly communicate while editing

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with the following nodes:
      | id   | parent_id | name                |
      | 100  | 0         | Pardosa             |

  @javascript
  Scenario: User cannot see a chat window unless there are contributors
    When I go to the master tree page for "Spiders"
    And I wait for the websocket to activate
    Then the chat window should be hidden

  @javascript
  Scenario: User can see the chat window when there is a contributor
    When a user "email2@person.com/password" already exists
    And "email2@person.com" is a contributor to the master tree "Spiders"
    When I go to the master tree page for "Spiders"
    And I wait for the websocket to activate
    Then the chat window should be visible

  @javascript
  Scenario: User can see a chat message he/she authors
    When a user "email2@person.com/password" already exists
    And "email2@person.com" is a contributor to the master tree "Spiders"
    When I go to the master tree page for "Spiders"
    And I wait for the websocket to activate
    And I follow "Maximize" within "#chat-messages-options"
    And I enter "I have just edited the tree" in the chat box and press enter
    Then I should see a chat message "I have just edited the tree" authored by "email@person.com"