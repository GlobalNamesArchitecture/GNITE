Feature: Browse GNACLR

  As a user
  I can browse trees in the GNACLR database in the "external work" pane
  So that I can find trees I may want to use in my work

  Background: I am editing a tree, and there are records in GNACLR
    Given GNACLR contains the following classifications:
      | title          | author_list                                          | description             | updated             | uuid |
      | NCBI           | Dmitry Mozzherin <dmitry@example.com>                | NCBI classification     | 2010-07-15 16:49:40 | 1    |
      | Index Fungorum | Paul Kirk <paul@paul.com>, Bob Lawblog <bob@bob.com> | Classification of Fungi | 2010-06-21 11:26:16 | 2    |
    And I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Waterpigs" with:
      | hydrochaeris |
    When I go to the master trees page
    And I follow "Waterpigs"

  @javascript
  Scenario: Browse GNACLR from "Import" interface
    When I follow "Import"
    And I follow "Browse Classifications"
    And I follow "NCBI"
    Then I should see "NCBI"
    And I should see "Dmitry Mozzherin"
    And "Dmitry Mozzherin" should link to email "dmitry@example.com"
    And I should see "NCBI classification"
    And I should see "2010-07-15"

  @javascript
  Scenario: View breadcrumb navigation while browsing GNACLR
    When I follow "Import"
    And I follow "Browse Classifications"
    And I follow "NCBI"
    Then I should see "NCBI"
    And I should see "Dmitry Mozzherin"

    When I follow "New Import" within the right panel header
    Then I should see "Browse Classifications"

  Scenario: Browse GNACLR from "New Master Tree" screen
