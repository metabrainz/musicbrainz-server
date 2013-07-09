The Developer's Guide to the MusicBrainz Server
===============================================

Testing
-------

We use standard Perl tools for unit testing. Tests are located in the t/
directory. The preferred way to run them is to use the `prove` program from
Test::Harness. For example, to run all tests use:

    $ prove -l t/

If you're using Carton, you should instead run:

    $ carton exec -Ilib -- prove t/

The bulk of tests will run from the single tests.t file, which can take a while
to complete. If you are only interested in running a single test, you can pass
the --tests option. For example if you want to run a controller test such as
t::MusicBrainz::Server::Controller::WS::2::LookupArtist you can use:

    $ carton exec -Ilib -- prove t/tests.t :: --tests WS::2::LookupArtist

The --tests argument takes a regular expression to match against the test
name. For example, run multiple tests you can use regular expression groups:

    $ carton exec -Ilib -- prove t/tests.t :: --tests '(Data::URL|Entity::URL)'

While to run all Data:: tests you can do the following:

    $ carton exec -Ilib -- prove t/tests.t :: --tests 'Data::'


Database tests (pgTAP)
----------------------

For unit testing database functions we use pgtap, on a recent Ubuntu
you can install pgtap like this:

    $ sudo apt-get install pgtap

To run the tests, pgtap needs to be able to connect to the test
database.  You can use environment variables for the database
configuration, the easiest way to set these is to use the provided
database_configuration script like this:

    $ eval `carton exec -Ilib -- script/database_configuration TEST`

Now that that is set up you can run individual pgtap tests like this:

    $ prove --verbose --source pgTAP t/pgtap/unaccent.sql

Or all of them like this:

    $ prove --verbose --source pgTAP t/pgtap/* t/pgtap/unused-tags/*



Cover art archive development
-----------------------------

The Cover Art features in musicbrainz are provided by
coverartarchive.org.  To add cover art support to your development set
up, see HACKING-CAA.md

Javascript
----------

We have a set of javascript unittests (using QUnit), which we run
using phantomjs, these will be skipped if phantomjs isn't found.

Currently we have a single QUnit test file to run javascript tests.
It can be tested inside the browser by visiting
http://test.musicbrainz.org/static/scripts/tests/all.html (or
http://localhost:3000/static/scripts/tests/all.html on your local
development checkout).

It is more fun to be able to run those tests on the commandline, this
can be done with phantomjs.

To install phantomjs:

    $ sudo apt-get install libqt4-dev libqt4-webkit     # on debian
    $ sudo apt-get install libqtwebkit-dev              # on ubuntu
    $ sudo apt-get install xvfb
    $ cd ~/opt
    ~/opt$ git clone git://github.com/ariya/phantomjs.git
    ~/opt$ cd phantomjs
    ~/opt/phantomjs$ qmake
    ~/opt/phantomjs$ make

Now you should be able to use it to run QUnit tests.  A testrunner is
available in root/static/scripts/tests:

    $ xvfb-run ~/opt/phantomjs/bin/phantomjs root/static/scripts/tests/phantom-qunit.js http://localhost:3000/static/scripts/tests/all.html


Cache
-----

Keys:

 * at:INT -- artist type by ID
 * ac:INT -- artist credit by ID
 * artist:INT -- artist by ID
 * artist:UUID -- artist ID by MBID (you need to do another lookup by ID)
 * blog:entries -- The lastest entries from blog.musicbrainz.org
 * cat:INT -- cover art type by ID
 * c:INT -- country by ID
 * g:INT -- gender by ID
 * label:INT -- label by ID
 * label:UUID -- label by MBID (you need to do another lookup by ID)
 * lng:INT -- language by ID
 * lt:INT -- label type by ID
 * link:INT -- link by ID
 * linktype:INT -- link type by ID
 * linkattrtype:INT -- link attribute type by ID
 * mf:INT -- medium format by ID
 * rgt:INT -- release group type by ID
 * rs:INT -- release status by ID
 * rp:INT -- release packaging by ID
 * scr:INT -- script by ID
 * stats:* -- various different statistics
 * tag:INT -- tag by ID
 * wikidoc:TEXT-INT -- wikidocs by page title and revision
 * wikidoc-index -- wikidocs index page
 * wizard_session:INT:INT:<MIXED> -- release editor (wizard) 
   sessions by catalyst session ID, RE (random) session ID, and other specifics
 * wt:INT -- work type by ID

Debug information
-----------------

If you have CATALYST_DEBUG set to true, in DBDefs, the built in server
(script/musicbrainz_server.pl) will run in a development environment. This will
cause debug information to be generated on every page, and all HTML pages will
have debug panels available to view this information. To get to these panels,
simply click the "?" icon in the top right of each page.
