Feature: Edit User Settings
  A user should be able to edit their own settings

  Scenario: User can change their email
    Given I have signed in with "email@person.com/password"
    When I go to the edit user settings page for "email@person.com"
    And I fill in "Email" with "newemail@person.com"
    And I press "Save changes"
    Then I should see "successfully updated your profile"
    When I sign out
    And I sign in as "newemail@person.com/password"
    Then I should see "Signed in"
    When I sign out
    And I sign in as "email@person.com/password"
    Then I should see "Bad email"
