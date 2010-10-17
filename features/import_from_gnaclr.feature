Feature: Importing trees from GNACLR
  Background:
    Given I have signed in with "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And GNACLR contains the following classifications:
      | title          | author_list                           | description             | updated             | uuid | file_url             |
      | NCBI           | Dmitry Mozzherin <dmitry@example.com> | NCBI classification     | 2010-07-15 16:49:40 | 1    | cyphophthalmi.tar.gz |
    And the GNACLR classification "NCBI" has the following revisions:
      | sequence_number | message                          | url                  | commited_date |
      | 2               | this is really the best revision | cyphophthalmi.tar.gz | 2010-02-01    |
      | 1               | this is the best revision        | cyphophthalmi.tar.gz | 2010-01-01    |
    And I am on the master tree index page
    And I follow "Moose tree"

  @javascript
  Scenario: Importing the sample NCBI tree
    Then I should see "All working trees (0)"
    When I follow "Browse GNACLR database"
    And I follow "NCBI"
    And I press "Import"
    Then I should see a spinner
    And I should not see the gnaclr import button
    When resque jobs are run
    Then I should not see a spinner
    And I should see an "NCBI" tab
    Then I should see "All working trees (1)"
    And I should see the breadcrumb path "Working Trees > NCBI"
    And I should see a node "Cyphophthalmi incertae sedis" at the root level in my reference tree "NCBI"
    And I should see a node "Opiliones" at the root level in my reference tree "NCBI"
    When I select the node "Opiliones"
    Then I should see "Daddy longlegs" as vernacular names for the "NCBI" tree

  @javascript
  Scenario: Importing an older revision of the sample NCBI tree
    Then I should see "All working trees (0)"
    When I follow "Browse GNACLR database"
    And I follow "NCBI"
    Then "this is really the best revision" should be checked
    When I choose "this is the best revision"
    And I press "Import"
    Then I should see a spinner
    And I should not see the gnaclr import button
    When resque jobs are run
    Then I should not see a spinner
    And I should see an "NCBI" tab
    Then I should see "All working trees (1)"
    And I should see the breadcrumb path "Working Trees > NCBI"
    And I should see a node "Cyphophthalmi incertae sedis" at the root level in my reference tree "NCBI"
    And I should see a node "Opiliones" at the root level in my reference tree "NCBI"

  @javascript
  Scenario: Importing the sample NCBI tree and reloading the page before it finishes
    Then I should see "All working trees (0)"
    When I follow "Browse GNACLR database"
    And I follow "NCBI"
    And I press "Import"
    Then I should see a spinner
    And I should not see the gnaclr import button
    When I reload the page
    Then I should see "All working trees (1)"
    When I follow "All working trees"
    And I follow "NCBI"
    Then I should see the breadcrumb path "Working Trees > NCBI"
    And I should not see any reference tree nodes
    And I should see a spinner
    When resque jobs are run
    And pause 2
    Then I should not see a spinner
    And I should see "All working trees (1)"
    And I should see a node "Cyphophthalmi incertae sedis" at the root level in my reference tree "NCBI"
    And I should see a node "Opiliones" at the root level in my reference tree "NCBI"
    When I select the node "Opiliones"
    Then I should see "Daddy longlegs" as vernacular names for the "NCBI" tree
