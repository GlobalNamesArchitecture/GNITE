Feature: Importing trees from GNACLR
  Background:
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And GNACLR contains the following classifications:
      | title          | author_list                           | description             | updated             | uuid | file_url             |
      | NCBI           | Dmitry Mozzherin <dmitry@example.com> | NCBI classification     | 2010-07-15 16:49:40 | 1    | cyphophthalmi.tar.gz |
    And the GNACLR classification "NCBI" has the following revisions:
      | sequence_number | id        | committed_date      | message                          | url                  |
      | 2               | abcdef123 | 2011-02-14 17:05:17 | this is really the best revision | cyphophthalmi.tar.gz |
      | 1               | 123abcdef | 2011-03-14 17:05:17 | this is the best revision        | cyphophthalmi.tar.gz |
    And I am on the master tree index page
    And I follow "Moose tree"

  @javascript
  Scenario: Importing the sample NCBI tree
    Then I should see "All reference trees (0)"
    When I follow "Browse Classifications"
    And I follow "NCBI"
    And I press "Import"
    Then I should see a spinner
    And I should not see the gnaclr import button
    When resque jobs are run
    Then I should not see a spinner
    And I should see an "NCBI" tab
    Then I should see "All reference trees (1)"
    And I should see the breadcrumb path "Reference Trees > NCBI"
    And I should see a node "Cyphophthalmi incertae sedis" at the root level in my reference tree "NCBI"
    And I should see a node "Opiliones" at the root level in my reference tree "NCBI"
    When I select the node "Opiliones"
    Then I should see "Daddy longlegs" as vernacular names for the "NCBI" tree

  @javascript
  Scenario: Importing an older revision of the sample NCBI tree
    Then I should see "All reference trees (0)"
    When I follow "Browse Classifications"
    And I follow "NCBI"
    Then "Published: 2011-02-14 17:05:17" should be checked
    When I choose "Published: 2011-03-14 17:05:17"
    And I press "Import"
    Then I should see a spinner
    And I should not see the gnaclr import button
    When resque jobs are run
    And pause 5
    Then I should not see a spinner
    And I should see an "NCBI" tab
    Then I should see "All reference trees (1)"
    And I should see the breadcrumb path "Reference Trees > NCBI"
    And I should see a node "Cyphophthalmi incertae sedis" at the root level in my reference tree "NCBI"
    And I should see a node "Opiliones" at the root level in my reference tree "NCBI"

  @javascript
  Scenario: Importing the sample NCBI tree and reloading the page before it finishes
    Then I should see "All reference trees (0)"
    When I follow "Browse Classifications"
    And I follow "NCBI"
    And I press "Import"
    Then I should see a spinner
    And I should not see the gnaclr import button
    When I reload the page
    Then I should see "All reference trees (1)"
    When I follow "All reference trees"
    And I follow "NCBI"
    Then I should see the breadcrumb path "Reference Trees > NCBI"
    And I should not see any reference tree nodes
    And I should see a spinner
    When resque jobs are run
    And pause 5
    Then I should not see a spinner
    And I should see "All reference trees (1)"
    And I should see a node "Cyphophthalmi incertae sedis" at the root level in my reference tree "NCBI"
    And I should see a node "Opiliones" at the root level in my reference tree "NCBI"
    When I select the node "Opiliones"
    Then I should see "Daddy longlegs" as vernacular names for the "NCBI" tree
