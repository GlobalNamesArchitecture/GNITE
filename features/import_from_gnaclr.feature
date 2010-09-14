Feature: Importing trees from GNACLR

  @javascript
  Scenario: Importing the sample NCBI tree
    Given I am signed up and confirmed as "email@person.com/password"
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    And I sign in as "email@person.com/password"
    And GNACLR contains the following classifications:
      | title          | author_list                           | description             | updated             | uuid | file_url             |
      | NCBI           | Dmitry Mozzherin <dmitry@example.com> | NCBI classification     | 2010-07-15 16:49:40 | 1    | cyphophthalmi.tar.gz |
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
