Feature: Lock reset
  In order to sign in if user is locked out
  A user
  Should be able to unlock it

    Scenario: User is locked out
      Given I am signed up and confirmed as "email@person.com/password"
      And "email@person.com" is locked out
      And I sign in as "email@person.com/badpassword"
      Then I should see "Your account is locked."

    Scenario: User is locked out and successfully requests an unlock
      Given I am signed up and confirmed as "email@person.com/password"
      And "email@person.com" is locked out
      And I sign in as "email@person.com/badpassword"
      When I request an unlock link to be sent to "email@person.com"
      Then I should see "You will receive an email"
      And an unlock message should be sent to "email@person.com"

    Scenario: User is locked out and unlocks account
      Given I am signed up and confirmed as "email@person.com/password"
      And "email@person.com" is locked out
      And I sign in as "email@person.com/badpassword"
      When I request an unlock link to be sent to "email@person.com"
      Then I should see "You will receive an email"
      And an unlock message should be sent to "email@person.com"

      When I follow the unlock link sent to "email@person.com"
      Then I should see "Your account was successfully unlocked"
      And I should be signed in
