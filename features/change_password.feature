Feature: Change password
  As a user
  I can change my password
  To keep my account secure

  @wip
  Scenario: User is not signed up
    Given I am signed up and confirmed as "email@person.com/password"
    When I sign in as "email@person.com/password"
    And I follow "Change Password"
    And I fill in "Choose Password" with "newpassword"
    And I fill in "Confirm Password" with "newpassword"
    And I press "Save this password"
    Then I should see "Signed in."

    When I sign out
    And I sign in as "email@person.com/newpassword"
    Then I should be signed in
