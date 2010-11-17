Feature: User searches gnaclr
  As a user
  I can search the gnaclr database
  so that it is easier to find the taxons I'm interested in

  Background:
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

  # @javascript
  # Scenario: Type in a search term
  #   Then I should see "Search Classifications"
  #   When I search for "agaricus"
  #   And the search results return
  #   Then I should see that "the Scientific Name tab" has 5 results
  #   And the search results should contain the following classifications:
  #     | rank | url                      | path                                                               | found as     | current name     | title          | description             | uuid                                 |
  #     | gen. | http://indexfungorum.org | Fungi/Basidiomycota/Agaricomycetes/Agaricales/Agaricaceae/Agaricus | current_name | Agaricus L. 1753 | Index Fungorum | Classification of Fungi | a9995ace-f04f-49e2-8e14-4fdbc810b08a |
  #   And the "Index Fungorum" result should have the following authors:
  #     | first name | last name | email           |
  #     | Paul       | Kirk      | p.kirk@cabi.org |

  # @javascript
  # Scenario: User imports a search classification
  #   When I search for "agaricus"
  #   And the search results return
  #   And I press "Import" next to the "Index Fungorum" classification
  #   Then I should see a spinner
  #   When resque jobs are run
  #   Then I should not see a spinner
  #   And I should see an "Agaricus L. 1753" tab
  #   And I should see the breadcrumb path "Working Trees > Agaricus L. 1753"

  @javascript
  Scenario: User searches but GNACLR responds with an error
    Given the GNACLR search service is unavailable
    When I search for "anything"
    And the search results return
    Then I should see "search request could not be processed"

  # @javascript
  # Scenario: User searches but returns to import
  #   Given I search for "agaricus"
  #   And the search results return
  #   When I follow "New Import"
  #   Then I should see "Browse Classifications"
