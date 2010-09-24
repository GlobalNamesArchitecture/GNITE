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
    When I search for "Leptogastrinae weslacensis"
    And the search results return
    Then I should see that "the Scientific Name tab" has 1 result
    And the search results should contain the following classifications:
      | rank    | url                                                                                                         | path                                                             | found as | current name                            | citation                                                 | title                                             | description                                                   | uuid                                 |
      | species | http://leptogastrinae.lifedesks.org/files/leptogastrinae/classification_export/shared/leptogastrinae.tar.gz | Leptogastrinae/Leptogastrini/Apachekolos/Apachekolos weslacensis | synonym  | Apachekolos weslacensis (Bromley, 1951) | Dikow, Torsten. 2010. The Leptogastrinae classification. | Leptogastrinae (Diptera: Asilidae) Classification | These are all the names in the Leptogastrinae classification. | f02f9ac3-4500-5e8e-8a5d-68c9917f3bde |
    And the result with uuid "f02f9ac3-4500-5e8e-8a5d-68c9917f3bde" should have the following authors:
      | first name | last name | email                   |
      | Keith      | Bayless   | keith.bayless@gmail.com |
      | Torsten    | Dikow     | dshorthouse@eol.org     |
