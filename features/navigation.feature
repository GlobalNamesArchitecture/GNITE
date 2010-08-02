Feature: Interact with navigation bar

  As a user, I can:
  - go to any of my trees
  - go to the edit profile page
  - go to the change password page

  Scenario: Navigating to Trees
    Given I have signed in with "belinda@belew.com/password"
    And "belinda@belew.com" has created an existing tree titled "belinda's tree" with:
      | belinda's node |
    When I go to the home page
    Then I should see the navigation bar
    When I follow "Master Trees"
    And I follow "belinda's tree"
    Then I should be on the tree page for "belinda's tree"

  Scenario: Navigating to the edit profile page
    Given I have signed in with "belinda@belew.com/password"
    Then I should see the navigation bar
    When I follow "Profile Settings"
    Then I should be on the edit user settings page for "belinda@belew.com"
