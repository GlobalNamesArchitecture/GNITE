Feature: Edit User Settings
  A user should be able to edit their own settings

  Scenario: User can change their email
    Given I have signed in with "email@person.com/password"
    When I go to the edit user settings page for "email@person.com"
