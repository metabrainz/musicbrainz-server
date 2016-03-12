The Developer's Guide to the MusicBrainz Server
===============================================

Organization
------------

Important folders are documented here, in alphabetical order.

 * **admin/**

   Various scripts for server maintenance and administration.

 * **lib/**

   The `-Ilib` in `plackup -Ilib` sets `@INC` to here on startup.

    * **DBDefs/**

      Server configuration.

    * **MusicBrainz/Server/**

      Perl code for the actual server.

       * **Controller/**

         [Catalyst](http://search.cpan.org/perldoc?Catalyst) actions.

       * **Data/**

         Methods for fetching data from the database. The results are typically
         converted to instances of some Entity class found under
         lib/MusicBrainz/Server/Entity/.

         If you see something like `$c->model('Foo')` in the controllers,
         that's accessing an instance of `MusicBrainz::Server::Data::Foo`.

       * **Edit/**

         Contains code relating to our edit system. There's a Moose class for
         each edit type defining how to insert, apply, and reject the edit. The
         classes also contain type constraints restricting what sort of data
         can be contained in the edit (i.e. the data column in the edit table).

       * **Entity/**

         Moose classes for all of our entities.

       * **Form/**

         [HTML::FormHandler](http://search.cpan.org/dist/HTML-FormHandler/)
         classes, where most forms rendered by Template Toolkit get handled.
         The controller will create an instance of the corresponding class
         here, and pass the request data to it. (See e.g.
         `MusicBrainz::Server::Controller::edit_action`). The form acts to
         validate the request data and return any errors.

         We have some forms that are mostly rendered client-side and submit
         JSON directly to some controller endpoint, which then performs its own
         validation. (See e.g. `/ws/js/edit`.) Those have nothing to do with
         the code here.

 * **root/**

   Mostly [Template Toolkit](http://www.template-toolkit.org/) templates (files
   ending in .tt). The directory structure mostly corresponds to Catalyst
   action paths.

    * **static/**

      Static resources used for the website.

       * **scripts/**

         Client-side JavaScript.

          * **tests/**

            JavaScript unit tests (see below).

       * **styles/**

         CSS/[Less](http://lesscss.org/).

 * **t/**

   Where the server tests live.


Testing
-------

Most tests require a test database that has to be created once:

    $ script/create_test_db.sh

We use standard Perl tools for unit testing. Tests are located in the t/
directory. The preferred way to run them is to use the `prove` program from
Test::Harness. For example, to run all tests use:

    $ prove -l t/

The bulk of tests will run from the single tests.t file, which can take a while
to complete. If you are only interested in running a single test, you can pass
the --tests option. For example if you want to run a controller test such as
t::MusicBrainz::Server::Controller::WS::2::LookupArtist you can use:

    $ prove -l t/tests.t :: --tests WS::2::LookupArtist

The --tests argument takes a regular expression to match against the test
name. For example, to run multiple tests you can use regular expression groups:

    $ prove -l t/tests.t :: --tests '(Data::URL|Entity::URL)'

While to run all Data:: tests you can do the following:

    $ prove -l t/tests.t :: --tests 'Data::'

### Database tests (pgTAP)

For unit testing database functions we use pgtap, on a recent Ubuntu
you can install pgtap like this:

    $ sudo apt-get install pgtap

To run the tests, pgtap needs to be able to connect to the test
database.  You can use environment variables for the database
configuration, the easiest way to set these is to use the provided
database_configuration script like this:

    $ eval `perl -Ilib script/database_configuration TEST`

Now that that is set up you can run individual pgtap tests like this:

    $ prove --verbose --source pgTAP t/pgtap/unaccent.sql

Or all of them like this:

    $ prove --verbose --source pgTAP t/pgtap/* t/pgtap/unused-tags/*

### JavaScript

We have a set of JavaScript unit tests (using https://github.com/substack/tape)
which can be run in a browser or under Node.js.

To run the tests in a browser, they must be compiled first:

    $ script/compile_resources.sh tests

After compilation has finished, open
http://localhost:5000/static/scripts/tests/all.html on your local development
server.

It is more fun to be able to run those tests on the command line. This can be
done with the following command:

    $ prove -l t/js.t


Reports
-------

[Reports](https://beta.musicbrainz.org/reports) are lists of potential problems
in MusicBrainz. These reports are generated daily by the
*[daily.sh](https://github.com/metabrainz/musicbrainz-server/blob/master/admin/cron/daily.sh)*
script.

Contents of reports are stored in separate tables in `report` schema of the
database.

### Generating reports

You can generate all reports using the *[RunReports.sh](https://github.com/metabrainz/musicbrainz-server/blob/master/admin/RunReports.pl)*
script:

    $ ./admin/RunReports.pl

To run a specific report (see https://github.com/metabrainz/musicbrainz-server/tree/master/lib/MusicBrainz/Server/Report),
specify its name in an argument:


    $ ./admin/RunReports.pl DuplicateArtists

### Adding a new report

1. Create new module in */lib/MusicBrainz/Server/Report/*.
2. Add created module into [ReportFactory.pm](https://github.com/metabrainz/musicbrainz-server/blob/master/lib/MusicBrainz/Server/ReportFactory.pm)
   file (add into `@all` list and import module itself there).
3. Create a new template for your report in *root/report/*.
4. Add a link to report page in *root/report/index.tt* template.


Cover Art Archive development
-----------------------------

The Cover Art features in MusicBrainz are provided by
[coverartarchive.org](https://coverartarchive.org/). Instructions for adding
cover art support to your development setup are available in HACKING-CAA.md
file.


Cache
-----

Keys:

 * area_type:INT -- area type by ID
 * artist_type:INT -- artist type by ID
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
 * label_type:INT -- label type by ID
 * link:INT -- link by ID
 * linktype:INT -- link type by ID
 * linkattrtype:INT -- link attribute type by ID
 * mf:INT -- medium format by ID
 * place_type:INT -- place type by ID
 * release_group_type:INT -- release group type by ID
 * release_group_secondary_type:INT -- release group secondary type by ID
 * rs:INT -- release status by ID
 * rp:INT -- release packaging by ID
 * scr:INT -- script by ID
 * stats:* -- various different statistics
 * tag:INT -- tag by ID
 * wikidoc:TEXT-INT -- wikidocs by page title and revision
 * wikidoc-index -- wikidocs index page
 * work_type:INT -- work type by ID


Debug information
-----------------

If you have CATALYST_DEBUG set to true, in DBDefs, the built in server
(script/musicbrainz_server.pl) will run in a development environment. This will
cause debug information to be generated on every page, and all HTML pages will
have debug panels available to view this information. To get to these panels,
simply click the "?" icon in the top right of each page.

Potential issues and fixes
--------------------------

### Images from Wikimedia Commons aren't loading

This might be caused by failed SSL verification. One way to confirm is to check
response that you get from Wikimedia Commons API in `Data::Role::MediaWikiAPI`.
If it is indeed the cause then you can install `Mozilla::CA` module:

    $ cpanm Mozilla::CA
