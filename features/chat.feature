Feature: Chat
  As a user
  I can chat with colleagues
  So that I can quickly communicate while editing

  Background: I have a master tree
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Spiders" with the following nodes:
      | id   | parent_id | name                |
      | 100  | 0         | Pardosa             |
    And I go to the master tree page for "Spiders"
    And I wait for the websocket to activate
    And I maximize the chat window

  @javascript
  Scenario: User can send a chat message
    When I enter "I have just edited the tree" in the chat box and press enter
    Then I should see a chat message "I have just edited the tree"