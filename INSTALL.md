Installing MusicBrainz Server
=============================

The easiest method of installing a local MusicBrainz Server may be to download the
[pre-configured virtual machine](https://musicbrainz.org/doc/MusicBrainz_Server/Setup),
if there is a current image available. In case you only need a replicated
database, you should consider using [mbslave](https://bitbucket.org/lalinsky/mbslave).

If you want to manually set up MusicBrainz Server from source, read on!

Prerequisites
-------------

1.  A Unix based operating system

    The MusicBrainz development team uses a variety of Linux distributions, but
    Mac OS X will work just fine, if you're prepared to potentially jump through
    some hoops. If you are running Windows we recommend you set up a Ubuntu virtual
    machine.

    **This document will assume you are using Ubuntu (at least 14.04) for its
    instructions.**

2.  Perl (at least version 5.18.2)

    Perl comes bundled with most Linux operating systems, you can check your
    installed version of Perl with:

        perl -v

3.  PostgreSQL (at least version 9.5)

    PostgreSQL is required, along with its development libraries. To install
    using packages run the following, replacing 9.x with the latest version.
    If needed, packages of all supported PostgreSQL versions for various Ubuntu
    releases are available from the [PostgreSQL apt repository](http://www.postgresql.org/download/linux/ubuntu/).

        sudo apt-get install postgresql-9.x postgresql-server-dev-9.x postgresql-contrib-9.x

    Alternatively, you may compile PostgreSQL from source, but then make sure to
    also compile the cube and earthdistance extensions found in the contrib
    directory. The database import script will take care of installing those
    extensions into the database when it creates the database for you.

4.  Git

    The MusicBrainz development team uses Git for their DVCS. To install Git,
    run the following:

        sudo apt-get install git-core

5.  Redis

    Sessions and cached entities are stored in Redis, so a running Redis server
    is required. Redis can be installed with the following command and will not
    need any further configuration:

        sudo apt-get install redis-server

    The databases and key prefix used by musicbrainz can be configured
    in lib/DBDefs.pm.  The defaults should be fine if you don't use
    your redis install for anything else.

6.  Node.js

    Node.js is required to build (and optionally minify) our JavaScript and CSS.
    If you plan on accessing musicbrainz-server inside a web browser, you should
    install Node and its package manager, npm. Do this by running:

        sudo apt-get install nodejs npm

    Depending on your Ubuntu version, another package might be required, too:

        sudo apt-get install nodejs-legacy

    This is only needed where it exists, so a warning about the package not being
    found is not a problem.

7.  Standard Development Tools

    In order to install some of the required Perl and Postgresql modules, you'll
    need a C compiler and make. You can install a basic set of development tools
    with the command:

        sudo apt-get install build-essential


Server configuration
--------------------

1.  Download the source code.

        git clone --recursive git://github.com/metabrainz/musicbrainz-server.git
        cd musicbrainz-server

2.  Modify the server configuration file.

        cp lib/DBDefs.pm.sample lib/DBDefs.pm

    Fill in the appropriate values for `MB_SERVER_ROOT` and `WEB_SERVER`.
    If you are using a reverse proxy, you should set the environment variable
    MUSICBRAINZ_USE_PROXY=1 when starting the server.
    This makes the server aware of it when checking for the canonical uri.

    Determine what type of server this will be and set `REPLICATION_TYPE` accordingly:

    1.  `RT_SLAVE` (mirror server)

        A mirror server will always be in sync with the master database at
        https://musicbrainz.org/ by way of an hourly replication packet. Mirror
        servers do not allow any local editing. After the initial data import, the
        only changes allowed will be to load the next replication packet in turn.

        Mirror servers will have their WikiDocs automatically kept up to date.

        If you are not setting up a mirror server for development purposes, make
        sure to set `DB_STAGING_SERVER` to 0.

        If you're setting up a slave server, make sure you have something set up
        for the READONLY database setting in lib/DBDefs.pm; it can just be a copy
        of what's in READWRITE if you don't need anything fancy.

    2.  `RT_STANDALONE`

        A stand alone server is recommended if you are setting up a server for
        development purposes. They do not accept the replication packets and will
        require manually importing a new database dump in order to bring it up to
        date with the master database. Local editing is available, but keep in
        mind that none of your changes will be pushed up to https://musicbrainz.org/.

    3. `RT_MASTER`

        Almost certainly not what you want, this is what the main musicbrainz.org
        site runs on. It's different from standalone in that it's able to *produce*
        replication packets to be applied on slaves. For more details, see
        INSTALL-MASTER.md


Installing Perl dependencies
----------------------------

The fundamental thing that needs to happen here is all the dependency Perl
modules get installed, somewhere where your server can find them. There are many
ways to make this happen, and the best choice will be very
site-dependent. MusicBrainz recommends the use of local::lib, which will install
Perl libraries into your home directory, and does not require root permissions
and avoids modifying the rest of your system.

Below outlines how to setup MusicBrainz server with local::lib.

1.  Prerequisites

    Before you get started you will actually need to have local::lib installed.
    There are also a few development headers that will be needed when installing
    dependencies. Run the following steps as a normal user on your system.

        sudo apt-get install libxml2-dev libpq-dev libexpat1-dev libdb-dev libicu-dev liblocal-lib-perl cpanminus

2.  Enable local::lib

    local::lib requires a few environment variables are set. The easiest way to
    do this is via .bashrc, assuming you use bash as your shell. Simply run the
    following to append local::lib configuration to your bash configuration:

        echo 'eval $( perl -Mlocal::lib )' >> ~/.bashrc

    Next, to reload your configuration, either close and open your shell again,
    or run:

        source ~/.bashrc

3.  Install dependencies

    To install the dependencies for MusicBrainz Server, make sure you are
    in the MusicBrainz source code directory and run the following:

        cpanm --installdeps --notest .

    (Do not overlook the dot at the end of that command.)

Installing Node.js dependencies
-------------------------------

Node dependencies are managed using `npm`. To install these dependencies, run
the following inside the musicbrainz-server/ checkout:

    npm install

Node dependencies are installed under ./node\_modules.

To build everything necessary to access the server in a web browser (CSS,
JavaScript), run the following command:

    ./script/compile_resources.sh


Creating the database
---------------------

1.  Install PostgreSQL Extensions

    Before you start, you need to install the PostgreSQL Extensions on your
    database server. To build the musicbrainz_unaccent extension run these
    commands:

        cd postgresql-musicbrainz-unaccent
        make
        sudo make install
        cd ..

    To build our collate extension you will need libicu and its development
    headers, to install these run:

        sudo apt-get install libicu-dev

    With libicu installed, you can build and install the collate extension by
    running:

        cd postgresql-musicbrainz-collate
        make
        sudo make install
        cd ..

2.  Setup PostgreSQL authentication

    For normal operation, the server only needs to connect from one or two OS
    users (whoever your web server/crontabs run as), to one database (the
    MusicBrainz Database), as one PostgreSQL user. The PostgreSQL database name
    and user name are given in DBDefs.pm (look for the `READWRITE` key).  For
    example, if you run your web server and crontabs as "www-user", the
    following configuration recipe may prove useful:

        # in pg_hba.conf (Note: The order of lines is important!):
        local    musicbrainz_db    musicbrainz    ident    map=mb_map

        # in pg_ident.conf:
        mb_map    www-user    musicbrainz

    Alternatively, if you are running a server for development purposes and
    don't require any special access permissions, the following configuration in
    pg_hba.conf will suffice (make sure to insert this line before any other
    permissions):

        local   all    all    trust

    By default, the password for the user musicbrainz should be "musicbrainz",
    as stated in lib/DBDefs.pm. You can change it with `psql`:

        postgres=# ALTER USER musicbrainz UNENCRYPTED PASSWORD 'musicbrainz'

    Note that a running PostgreSQL will pick up changes to configuration files
    only when being told so via a `HUP` signal.

3.  Create the database

    You have two options when it comes to the database. You can either opt for a
    clean database with just the schema (useful for developers with limited disk
    space), or you can import a full database dump.

    1.  Use a clean database

        To use a clean database, all you need to do is run:

            ./admin/InitDb.pl --createdb --clean

    2.  Import a database dump

        Our database dumps are provided twice a week and can be downloaded from
        ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/

        To get going, you need at least the mbdump.tar.bz2,
        mbdump-editor.tar.bz2 and mbdump-derived.tar.bz2 archives, but you can
        grab whichever dumps suit your needs.

        Assuming the dumps have been downloaded to /tmp/dumps/ you can verify
        that the data is correct by running:

            pushd /tmp/dumps/ && md5sum -c MD5SUMS && popd

        You can also verify that the data dumps were indeed created by
        MusicBrainz verifying them against our GPG signing key:

            gpg --recv-keys C777580F
            gpg --verify-files /tmp/dumps/*.asc

        Before you can actually import the dumps, make sure that bzip2 is installed:

            apt-get install bzip2

        If the GPG signing key is OK and you wish to continue, you can import them with:

            ./admin/InitDb.pl --createdb --import /tmp/dumps/mbdump*.tar.bz2 --echo

        `--echo` just gives us a bit more feedback in case this goes wrong, you
        may leave it off. Remember to change the paths to your mbdump*.tar.bz2
        files, if they are not in /tmp/dumps/.

        By default, the archives will be extracted into the `/tmp` directory as
        an intermediate step. You may specify a different location with the
        `--tmp-dir` option.

    NOTE: on a fresh postgresql install you may see the following error:

        CreateFunctions.sql:33: ERROR:  language "plpgsql" does not exist

    To resolve that login to postgresql with the "postgres" user (or any other
    postgresql user with SUPERUSER privileges) and load the "plpgsql" language
    into the database with the following command:

        postgres=# CREATE LANGUAGE plpgsql;

    MusicBrainz Server doesn't enforce any statement timeouts on any SQL it runs.
    If this is an issue in your setup, you may want to set a timeout at the
    database level:

        ALTER DATABASE musicbrainz_db SET statement_timeout TO 60000;


Starting the server
-------------------

You should now have everything ready to run the development server!

The development server is a lightweight HTTP server that gives good debug
output and is much more convenient than having to set up a standalone
server. Just run:

    plackup -Ilib -r

Visiting http://your.machines.ip.address:5000/ should now present you with
your own running instance of the MusicBrainz Server.

If you'd like a more permanent setup,
[the plackup documentation](https://metacpan.org/pod/plackup) may prove useful
in setting up a server such as nginx, using FastCGI.


Rate limiting
-------------

The server by itself doesn't rate limit any request it handles. If you're
receiving 503s, then you're likely performing
[search queries](https://musicbrainz.org/doc/Search_Server) without having set
up a local instance of the
[search server](https://bitbucket.org/metabrainz/search-server). By default,
search queries are sent to search.musicbrainz.org and are rate limited.

Once you set up your own instance, change `LUCENE_SERVER` in lib/DBDefs.pm to
point to it.


Translations
------------

If you intend to run a server with translations, there are a few steps to follow:

1.  Prerequisites

    Make sure gettext is installed (you need msgmerge and msgfmt, at least),
    and the transifex client 'tx'
    (http://help.transifex.com/features/client/index.html):

        sudo apt-get install gettext transifex-client

    Configure a username and password in ~/.transifexrc using the format listed
    on the above page.

2.  Change to the po directory

        cd po/

3.  Get translations

        tx pull -l {a list of languages you want to pull}

    This will download the .po files for your language(s) of choice to the po/
    folder with the correct filenames.

4.  Install translations

        make install

    This will compile and install the files to
    lib/LocaleData/{language}/LC\_MESSAGES/{domain}.mo

5.  Add the languages to MB\_LANGUAGES in DBDefs.pm. These should be formatted
    {lang}-{country}, e.g. 'es', or 'fr-ca', in a space-separated list.

6.  Ensure you have a system locale for any languages you want to use, and for
    some languages, be wary of https://rt.cpan.org/Public/Bug/Display.html?id=78341

    For many languages, this will suffice:

        sudo apt-get install language-pack-{language code}

    To work around the linked CPAN bug, you may need to edit the file for Locale::Util
    to add entries to LANG2COUNTRY. Suggested ones include:

    * es => 'ES'
    * et => 'EE'
    * el => 'GR'
    * sl => 'SI' (this one is there in 1.20, but needs amendment)


Troubleshooting
---------------

If you have any difficulties, feel free to ask in #metabrainz on irc.freenode.net,
or ask on [our forums](https://community.metabrainz.org/c/musicbrainz).

Please report any issues on our [bug tracker](http://tickets.musicbrainz.org/).

Good luck, and happy hacking!
