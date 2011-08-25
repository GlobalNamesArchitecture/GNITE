Feature: User profile
  As a user
  I can adjust my profile settings
  To keep my account up-to-date

  Scenario: User can change their password
    Given I have signed in with "email@person.com/password"
    And I follow "Profile Settings"
    And I fill in "New password" with "newpassword"
    And I fill in "Password confirmation" with "newpassword"
    And I fill in "Current password" with "password"
    And I press "Save changes"
    Then I should see "You updated your account successfully."
    When I sign out
    And I sign in as "email@person.com/newpassword"
    Then I should be signed in

  Scenario: User can change their email
    Given I have signed in with "email@person.com/password"
    When I go to the edit user settings page
    And I fill in "Email" with "newemail@person.com"
    And I fill in "Current password" with "password"
    And I press "Save changes"
    Then I should see "You updated your account successfully."
    When I sign out
    And I sign in as "newemail@person.com/password"
    Then I should see "Signed in successfully."
    When I sign out
    And I sign in as "email@person.com/password"
    Then I should see "Invalid email or password."