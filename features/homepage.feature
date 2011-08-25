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
    Then I should see "Signed in successfully"
    And I should be signed in

  Scenario: Signing up from the homepage
    When I go to the home page
    And I follow "Sign up"
    Then I should be on the sign up page

  Scenario: Resetting my password from the homepage
    When I go to the home page
    And I follow "Forgot your password?"
    Then I should be on the password reset request page

  Scenario: Resend confirmation instructions from the homepage
    When I go to the homepage
    And I follow "Didn't receive confirmation instructions?"
    Then I should be on the resend confirmation page

  Scenario: Resend unlock instructions from the homepage
    When I go to the homepage
    And I follow "Didn't receive unlock instructions?"
    Then I should be on the resend unlock instructions page
