Feature: Browse GNACLR

  As a user
  I can browse trees in the GNACLR database in the "external work" pane
  So that I can find trees I may want to use in my work

  Background: I am editing a tree, and there are records in GNACLR
    Given GNACLR contains the following classifications:
      | title          | author_list                                          | description             | updated             | uuid |
      | NCBI           | Dmitry Mozzherin <dmitry@example.com>                | NCBI classification     | 2010-07-15 16:49:40 | 1    |
      | Index Fungorum | Paul Kirk <paul@paul.com>, Bob Lawblog <bob@bob.com> | Classification of Fungi | 2010-06-21 11:26:16 | 2    |
    # TODO: GNACLR must implement a way to fetch revisions for a classification via API before this is possible
    #
    # And the GNACLR classification "NCBI" has the following revisions:
    #   | message                   |
    #   | 2010-07-15 at 04:49:40 PM |
    # And the GNACLR classification "Index Fungorum" has the following revisions:
    #   | message                   |
    #   | 2010-06-21 at 11:26:16 AM |
    #   | 2010-06-03 at 04:18:41 PM |
    #   | 2010-06-03 at 02:53:54 PM |
    #   | 2010-06-03 at 02:47:03 PM |
    #   | 2010-06-03 at 02:39:44 PM |
    #   | 2010-06-02 at 01:46:10 PM |
    And I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing tree titled "Waterpigs" with:
      | hydrochaeris |
    When I go to the trees page
    And I follow "Waterpigs"

  @javascript
  Scenario: Browse GNACLR from "New Tab" interface
    When I follow "New Tab"
    And I follow "Browse GNACLR Database"
    And I follow "NCBI"
    Then I should see "NCBI"
    And I should see "Dmitry Mozzherin"
    And "Dmitry Mozzherin" should link to email "dmitry@example.com"
    And I should see "NCBI classification"
    And I should see "2010-07-15"
    # TODO: GNACLR must implement a way to fetch revisions for a classification via API before this is possible
    #
    # And I should see "1 revision"
    # And I should see "2010-07-15 at 04:49:40 PM"

  Scenario: View breadcrumb navigation while browsing GNACLR
  Scenario: Browse GNACLR from "New Master Tree" screen
