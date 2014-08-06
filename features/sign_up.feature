Feature: Sign up
  In order to get access to protected sections of the site
  A user
  Should be able to sign up

    Scenario: User signs up with invalid email address
      When I go to the sign up page
      And I fill in "Email" with "invalidemail"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with "password"
      And I press "Sign up"
      Then I should see "is invalid" within "#user_email_input"

    Scenario: User signs up with invalid password that is too short
      When I go to the sign up page
      And I fill in "Email" with "user@person.com"
      And I fill in "Password" with "pass"
      And I fill in "Confirm password" with "pass"
      And I press "Sign up"
      Then I should see "is too short" within "#user_password_input"

    Scenario: User signs up with invalid confirmation password
      When I go to the sign up page
      And I fill in "Email" with "user@person.com"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with "password1"
      And I press "Sign up"
      Then I should see "doesn't match Password" within "#user_password_confirmation_input"

    Scenario: User signs up with an account that is already taken
      When a user "email@person.com/password" already exists
      And I go to the sign up page
      And I fill in "Email" with "email@person.com"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with "password"
      And I press "Sign up"
      Then I should see "has already been taken" within "#user_email_input"

    Scenario: User signs up with valid data
      When I go to the sign up page
      And I fill in "Email" with "email@person.com"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with "password"
      And I press "Sign up"
      Then I should see "A message with a confirmation link has been sent to your email address"
      And a confirmation message should be sent to "email@person.com"

    Scenario: User confirms his account
      Given I signed up with "email@person.com/password"
      When I follow the confirmation link sent to "email@person.com"
      Then I should see "Your account was successfully confirmed"

    Scenario: User is directed to tree index after sign up
      Given I signed up with "email@person.com/password"
      When I follow the confirmation link sent to "email@person.com"
      Then I should be on the sign in page
