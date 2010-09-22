Feature: Importing trees from GNACLR
  Background:
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And GNACLR contains the following classifications:
      | title          | author_list                           | description             | updated             | uuid | file_url             |
      | NCBI           | Dmitry Mozzherin <dmitry@example.com> | NCBI classification     | 2010-07-15 16:49:40 | 1    | cyphophthalmi.tar.gz |
    And the GNACLR classification "NCBI" has the following revisions:
      | sequence_number | message                          | url                  | commited_date |
      | 2               | this is really the best revision | cyphophthalmi.tar.gz | 2010-02-01    |
      | 1               | this is the best revision        | cyphophthalmi.tar.gz | 2010-01-01    |

  @javascript
  Scenario: Importing the sample NCBI tree
    When I sign in as "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "Moose tree"
    And I follow "Browse GNACLR Database"
    And I follow "NCBI"
    And I press "Import"
    Then I should see a spinner
    When delayed jobs are run
    Then I should not see a spinner
    And I should see an "NCBI" tab
    And the "NCBI" tab should be active
    And I should see a node "Cyphophthalmi incertae sedis" at the root level in my reference tree "NCBI"
    And I should see a node "Opiliones" at the root level in my reference tree "NCBI"

  @javascript
  Scenario: Importing an older revision of the sample NCBI tree
    When I sign in as "email@person.com/password"
    Then I should be on the master tree index page
    When I follow "Moose tree"
    And I follow "Browse GNACLR Database"
    And I follow "NCBI"
    Then "this is really the best revision" should be checked
    When I choose "this is the best revision"
    And I press "Import"
    Then I should see a spinner
    When delayed jobs are run
    Then I should not see a spinner
    And I should see an "NCBI" tab
    And the "NCBI" tab should be active
    And I should see a node "Cyphophthalmi incertae sedis" at the root level in my reference tree "NCBI"
    And I should see a node "Opiliones" at the root level in my reference tree "NCBI"
