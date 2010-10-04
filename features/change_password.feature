Feature: Change password
  As a user
  I can change my password
  To keep my account secure

  Scenario: Changing the password for the current user
    Given I have signed in with "email@person.com/password"
    And I follow "Profile Settings"
    When I follow "Change Password"
    And I fill in "Choose password" with "newpassword"
    And I fill in "Confirm password" with "newpassword"
    And I press "Save this password"
    Then I should see "Password changed."
    When I sign out
    And I sign in as "email@person.com/newpassword"
    Then I should be signed in

  Scenario: Cancel password change
    Given I have signed in with "email@person.com/password"
    And I follow "Profile Settings"
    When I follow "Change Password"
    And I follow "Profile Settings"
    Then I should be on the edit user settings page for "email@person.com"
