Installing MusicBrainz Server
=============================

The easiest method of installing a local MusicBrainz Server may be to use the
[MusicBrainz Docker](https://github.com/metabrainz/musicbrainz-docker) Compose
project, which can be used for a website/web service mirror, testing, or
development. In case you only need a replicated database, you should consider
using [mbdata](https://github.com/lalinsky/mbdata).

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

2.  Perl (at least version 5.30)

    Perl comes bundled with most Linux operating systems, you can check your
    installed version of Perl with:

        perl -v

3.  PostgreSQL (at least version 12)

    PostgreSQL version 12 or higher is required, along with its development
    libraries. To install using packages, run the following:

        POSTGRES_VERSION=12 \
        sudo apt-get install \
            postgresql-${POSTGRES_VERSION} \
            postgresql-contrib-${POSTGRES_VERSION} \
            postgresql-server-dev-${POSTGRES_VERSION}

    If needed, packages of all supported PostgreSQL versions for various Ubuntu
    releases are available from the
    [PostgreSQL apt repository](http://www.postgresql.org/download/linux/ubuntu/).

    Alternatively, you may compile PostgreSQL from source, but then make sure to
    also compile the cube and earthdistance extensions found in the contrib
    directory. The database import script will take care of installing those
    extensions into the database when it creates the database for you.

4.  Git

    The MusicBrainz development team uses Git for their DVCS. To install Git,
    run the following:

        sudo apt-get install git

5.  Redis

    Sessions and cached entities are stored in Redis, so a running Redis server
    is required. Redis can be installed with the following command and will not
    need any further configuration:

        sudo apt-get install redis-server

    The databases and key prefix used by musicbrainz can be configured
    in lib/DBDefs.pm.  The defaults should be fine if you don't use
    your redis install for anything else.

6.  Node.js (at least version 16) and Yarn

    Node.js is required to build (and optionally minify) our JavaScript and CSS.
    If you plan on accessing musicbrainz-server inside a web browser, you should
    install Node and the package manager Yarn.

    We currently run Node.js v16.16.0 in production.  While we try to support
    all 16.x versions of Node, it's recommended to install one greater than or
    equal to v16.13.0, as this is when the LTS line started and better matches
    what we use and know works.  If your release of Ubuntu doesn't have such a
    version of Node.js in its repositories, we can recommended the NodeSource
    binary distributions, which we also use in production:

        https://github.com/nodesource/distributions#installation-instructions

    To install Node.js from either the Ubuntu or NodeSource repositories, run:

        sudo apt-get install nodejs

    Depending on your Ubuntu version, another package might be required, too:

        sudo apt-get install nodejs-legacy

    This is only needed where it exists, so a warning about the package not being
    found is not a problem.

    Next you need Yarn to install the JS dependencies. There are a variety of
    installation methods described on their website, located here:
    https://yarnpkg.com/en/docs/install

7.  Standard Development Tools

    In order to install some of the required Perl and Postgresql modules, you'll
    need a C compiler and make. You can install a basic set of development tools
    with the command:

        sudo apt-get install build-essential

8.  Script dependencies

    In order to run one-off scripts, you’ll need the `ts` command which is provided
    by the `moreutils` package. If needed, you can install it with the command:

        sudo apt-get install moreutils

Server configuration
--------------------

1.  Download the source code.

        git clone --recursive git://github.com/metabrainz/musicbrainz-server.git
        cd musicbrainz-server

2.  Modify the server configuration file.

        cp lib/DBDefs.pm.sample lib/DBDefs.pm

    Fill in the appropriate value (according to comments) for `WEB_SERVER`.
    If you are using a reverse proxy, you should set the environment variable
    MUSICBRAINZ_USE_PROXY=1 when starting the server.
    This makes the server aware of it when checking for the canonical uri.

    Determine what type of server this will be and set `REPLICATION_TYPE` accordingly:

    1.  `RT_MIRROR` (mirror server)

        A mirror server will always be in sync with the master database at
        https://musicbrainz.org/ by way of an hourly replication packet. Mirror
        servers do not allow any local editing. After the initial data import, the
        only changes allowed will be to load the next replication packet in turn.

        Mirror servers will have their WikiDocs automatically kept up to date.

        If you are not setting up a mirror server for development purposes, make
        sure to set `DB_STAGING_SERVER` to 0.

        If you're setting up a mirror server, make sure you have something set up
        for the READONLY database setting in lib/DBDefs.pm; it can just be a copy
        of what's in READWRITE if you don't need anything fancy.

    2.  `RT_STANDALONE` (for development)

        A stand alone server is recommended if you are setting up a server for
        development purposes. They do not accept the replication packets and will
        require manually importing a new database dump in order to bring it up to
        date with the master database. Local editing is available, but keep in
        mind that none of your changes will be pushed up to https://musicbrainz.org/.

    3. `RT_MASTER`

        Almost certainly not what you want, this is what the main musicbrainz.org
        site runs on. It's different from standalone in that it's able to *produce*
        replication packets to be applied on mirrors. For more details, see
        INSTALL-MASTER.md

    The server type cannot easily be changed after data import.


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

        sudo apt-get install \
            libdb-dev \
            libexpat1-dev \
            libicu-dev \
            liblocal-lib-perl \
            libpq-dev \
            libxml2 \
            libxml2-dev \
            cpanminus \
            pkg-config

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

Building static web resources
-------------------------------

To build everything necessary to access the server in a web browser (CSS,
JavaScript), run the following command:

    ./script/compile_resources.sh

This command takes care of installing Node.js dependencies for you, including
development dependencies. If you're just setting up a mirror and don't plan
to hack on any code, you can save a bit of time and space by excluding the
devDependencies (listed in package.json):

    NODE_ENV=production ./script/compile_resources.sh

Creating the database
---------------------

1.  Setup PostgreSQL authentication

    For normal operation, the server only needs to connect from one or two OS
    users (whoever your web server/crontabs run as), to one database (the
    MusicBrainz Database), as one PostgreSQL user. The PostgreSQL database name
    and user name are given in DBDefs.pm (look for the `READWRITE` key).
    
    For example, if you run your web server and crontabs as "www-user" and you have
    kept the default PostgreSQL user name ("musicbrainz"), you could set up that user
    by changing your PostgreSQL configuration (the location of the PostegreSQL config
    varies depending on your operating ystem; in Ubuntu it's usually 
    /etc/postgresql/{version}/main/):
    
    1. Add this line in pg_hba.conf (Note: The order of the columns is important!):

           local    musicbrainz_db    musicbrainz    ident    map=mb_map
       
    2. Add this line in pg_ident.conf:

           mb_map    www-user    musicbrainz

    Alternatively, if you are running a server for development purposes and
    don't require any special access permissions, only adding this line in 
    pg_hba.conf will suffice (make sure to insert it before any other
    permissions):

        local   all    all    trust

    Note that a running PostgreSQL will pick up changes to configuration files
    only when being told so via a `HUP` signal (or by using pg_ctlcluster,
    specifying `reload` as action). Alternatively, in Ubuntu you can restart 
    PostgreSQL by using:
    
        sudo /etc/init.d/postgresql restart

    You do not need to create the PostgreSQL user ("musicbrainz", or whatever
    name you configured in DBDefs.pm) yourself; the next step will do so
    (using the password from DBDefs.pm) if it does not exist yet.

2.  Create the database

    You have three options when it comes to the database. You can opt for a
    clean database with just the schema, a sample of database content (useful 
    for developers with limited disk space), or you can import a full database dump.

    1.  Use a clean database

        To use a clean database, all you need to do is run:

            ./admin/InitDb.pl --createdb --clean

    2.  Import a database dump

        Our database dumps are provided twice a week and can be downloaded from
        [from a variety of locations](https://musicbrainz.org/doc/MusicBrainz_Database/Download#Download).
        That page also describes the contents of the various dump files.

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

    3.  Import a database sample

        If a full dump is too large for your purposes, but you would like to have some
        real data to test with for development, you can download our database sample,
        published once a month. This can be found at the same places the full dump is
        found (see above), but using `sample` instead of `fullexport` in the URL.
        For example: http://ftp.musicbrainz.org/pub/musicbrainz/data/sample/.

        You can import this sample dump in the same way as the full dump above.

    4.  Build materialized tables (optional but recommended)

        MusicBrainz Server makes use of materialized (or denormalized) tables in
        production to improve the performance of certain pages and features. These
        tables duplicate primary table data and can take up several additional
        gigabytes of space, so they're optional but recommended. If you don't populate
        these tables, we'll generally fall back to slower queries in their place.

        In order to build them initially, run the following script:

            ./admin/BuildMaterializedTables --database=MAINTENANCE all

        Once this is done, the tables will be kept up-to-date automatically via
        triggers. (This is true even on replicated mirrors. Generally, triggers
        are not created on mirrors, but since these materialized tables aren't
        replicated, we install a set of mirror-only triggers to manage them.)

    If this process gets interrupted or fails, you will need to manually drop the
    musicbrainz_db database in order to be able to run `./admin/InitDb.pl --createdb`
    again.

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
[search server](https://github.com/metabrainz/mb-solr) along with the
[search index rebuilder](https://github.com/metabrainz/sir). By default,
search queries are sent to search.musicbrainz.org and are rate limited.

Once you set up your own instance, change `SEARCH_SERVER` in lib/DBDefs.pm to
point to it.


Translations
------------

If you intend to run a server with translations, there are a few steps to follow:

1.  Prerequisites

    Make sure gettext is installed (you need msgmerge and msgfmt, at least):

        sudo apt-get install gettext

    This will enable you to compile and install the translations that are in
    the source repository.
    
    If you want to get the latest translation files or partial work-in-progress
    translations, or wish to work on translations yourself, you will need to
    create a [Transifex](https://www.transifex.com/) account and install its
    client software (`tx`):

        sudo apt-get install transifex-client

    More information (and alternative ways to install the client) can be found
    [here](https://docs.transifex.com/client/introduction/).

    Next, [create an API token](https://www.transifex.com/user/settings/api/)
    and use it to configure your credentials in
    [`~/.transifexrc`](https://docs.transifex.com/client/client-configuration#-transifexrc).
    
    Finally, you will need to join the
    [MetaBrainz Foundation organization](https://www.transifex.com/musicbrainz/public/)
    on Transifex to get access to the translations. If you wish to work on
    translations, you will also need to
    [join a language team](https://www.transifex.com/musicbrainz/musicbrainz/dashboard/).
    More information on how to get started can be found on
    [the MusicBrainz site](https://musicbrainz.org/doc/Server_Internationalisation).

2.  Change to the po directory

        cd po/

3.  Get translations

        tx pull -l {a list of languages you want to pull}

    This will download the .po files for your language(s) of choice to the po/
    folder with the correct filenames. Languages are written as an ISO language
    code, optionally followed by an underscore and an ISO country code (e.g. `fr`
    for French, `fr_CA` for Canadian French).

    Or, if you want to get _all_ translations instead:

        tx pull -a

    If you get `Forbidden` errors from `tx pull`, you will need to make sure
    you have joined the MusicBrainz organization and/or project (see point 1).

4.  Install translations

        make install

    This will compile and install the files to
    `lib/LocaleData/{language}/LC_MESSAGES/{domain}.mo`.

5.  Add the languages to `MB_LANGUAGES` in DBDefs.pm. These should be formatted
    {lang}-{country}, e.g. 'es', or 'fr-ca', in a space-separated list.

6.  Ensure you have a system locale for any languages you want to use. For many
    languages, this will suffice:

        sudo apt-get install language-pack-{language code}


Troubleshooting
---------------

If you have any difficulties, feel free to ask in #metabrainz on irc.libera.chat,
or ask on [our forums](https://community.metabrainz.org/c/musicbrainz).

Please report any issues on our [bug tracker](http://tickets.metabrainz.org/).

Good luck, and happy hacking!
