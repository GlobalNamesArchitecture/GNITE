Feature: User searches gnaclr
  As a user
  I can search the gnaclr database
  so that it is easier to find the taxons I'm interested in

  @javascript
  Scenario: Type in a search term
    Given I have signed in with "email@person.com/password"
    And GNACLR contains the following classifications:
      | title          | author_list                           | description             | updated             | uuid | file_url             |
      | NCBI           | Dmitry Mozzherin <dmitry@example.com> | NCBI classification     | 2010-07-15 16:49:40 | 1    | cyphophthalmi.tar.gz |
    And the GNACLR classification "NCBI" has the following revisions:
      | sequence_number | message       | url                  | commited_date |
      | 1               | best revision | cyphophthalmi.tar.gz | 2010-01-01    |
    And "email@person.com" has created an existing master tree titled "Moose tree" with:
      | Bullwinkle |
    When I go to the master tree index page
    And I follow "Moose tree"
    And I follow "Import"
    Then I should see "Search GNACLR database"
    When I search for "agaricus"
    And the search results return
    Then I should see that "the Scientific Name tab" has 5 results
    And the search results should contain the following classifications:
      | rank | url                      | path                                                               | found as     | current name     | title          | description             | uuid                                 |
      | gen. | http://indexfungorum.org | Fungi/Basidiomycota/Agaricomycetes/Agaricales/Agaricaceae/Agaricus | current_name | Agaricus L. 1753 | Index Fungorum | Classification of Fungi | a9995ace-f04f-49e2-8e14-4fdbc810b08a |
    And the result with uuid "a9995ace-f04f-49e2-8e14-4fdbc810b08a" should have the following authors:
      | first name | last name | email           |
      | Paul       | Kirk      | p.kirk@cabi.org |
