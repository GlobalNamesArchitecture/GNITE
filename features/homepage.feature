Feature: Sign in, sign up, and reset password from the homepage

  As a visitor or user
  I should be able to sign in, sign up, or reset my password from the homepage
  So I can get started using the application

  Scenario: Signing in from the homepage
    Given I am signed up and confirmed as "email@person.com/password"
    When I go to the home page
    And I fill in "Email" with "email@person.com"
    And I fill in "Password" with "password"
    And I press "Sign in"
    Then I should see "Signed in"
    And I should be signed in

  Scenario: Signing up from the homepage
    When I go to the home page
    And I follow "Sign up here"
    Then I should be on the sign up page

  Scenario: Resetting my password from the homepage
    When I go to the home page
    And I follow "Reset it here"
    Then I should be on the password reset request page
