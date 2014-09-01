Global Names Integrated Taxonomic Editor (GNITE)
================================================

GNITE is a an editor for taxonomic trees.

Install
-------

General Requirements

  - Ruby version 2.1.2 or higher
  - MySQL server version 5.1 or higher
  - Web Server for production (Nginx or Apache)

### required packages for Ubuntu:

    suso apt-get update
    sudo apt-get install mysql-server
    
You will need UTF-8 encoding and collation for your tables: You would need 
follwing in your my.cnf as minimum:

    character-set-server        = utf8
    character_set_filesystem    = utf8
    init-connect                = "SET NAMES utf8"

Running Tests
-------------

    bundle exect rake db:drop:all #if needed
    bundle exect rake db:create:all
    bundle exect rake db:schema:load RAILS_ENV=test
    bundle exect rake db:migrate RAILS_ENV=test #if there are new ones
    bundle exect rake db:seed RAILS_ENV=test
    rake 
    cucumber
    
QUEUES & WORKERS
----------------

RAILS_ENV=production RAKE_ENV=production QUEUE=gnaclr_importer rake resque:work
RAILS_ENV=production RAKE_ENV=production QUEUE=merge_event rake resque:work
RAILS_ENV=production RAKE_ENV=production QUEUE=gnite_not_destructive rake resque:work
./script/roster_listener


Copyright
---------

Code: [David Shorthouse][1], [Thoughtbot][2], 
[Dmitry Mozzherin][3], [Patric Leary][4]

Copyright 2011-2014 [Marine Biological Laboratory][]. 
See [LICENSE][5] for further details.

[1]: https://github.com/dshorthouse
[2]: https:/://github.com/thoughtbot 
[3]: https://github.com/dimus
[4]: https://github.com/pleary
[5]: https://raw.githubusercontent.com/GlobalNamesArchitecture/GNITE/master/LICENSE
