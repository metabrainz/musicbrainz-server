Installing MusicBrainz Server
=============================

The easiest method of installing a local MusicBrainz Server is to download the 
[pre-configured virtual machine](http://musicbrainz.org/doc/MusicBrainz_Server/Setup).

If you want to manually set up MusicBrainz Server from source, read on!

Prerequisites
-------------

1.  A Unix based operating system

    The MusicBrainz development team uses a variety of Linux distributions, but 
    Mac OS X will work just fine, if you're prepared to potentially jump through 
    some hoops. If you are running Windows we recommend you set up a Ubuntu virtual
    machine.

    **This document will assume you are using Ubuntu for its instructions.**

2.  Perl (at least version 5.10.1)

    Perl comes bundled with most Linux operating systems, you can check your
    installed version of Perl with:

        perl -v

3.  PostgreSQL (at least version 9.1)

    PostgreSQL is required, along with its development libraries. To install
    using packages run the following, replacing 9.x with the latest version.

        sudo apt-get install postgresql-9.x postgresql-server-dev-9.x postgresql-contrib-9.x

    Alternatively, you may compile PostgreSQL from source, but then make sure to
    also compile the cube extension found in contrib/cube. The database import
    script will take care of installing that extension into the database when it
    creates the database for you.

4.  Git

    The MusicBrainz development team uses Git for their DVCS. To install Git,
    run the following:

        sudo apt-get install git-core

5.  Memcached

    By default the MusicBrainz server requires a Memcached server running on the
    same server with default settings. To install Memcached, run the following:

        sudo apt-get install memcached

    You can change the memcached server name and port, or configure other datastores
    in lib/DBDefs.pm.

6.  Redis

    Sessions are stored in Redis, so a running Redis server is
    required.  Redis can be installed with the
    following command and will not need any further configuration:

        sudo apt-get install redis-server

    The databases and key prefix used by musicbrainz can be configured
    in lib/DBDefs.pm.  The defaults should be fine if you don't use
    your redis install for anything else.


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
        http://musicbrainz.org by way of an hourly replication packet. Mirror
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
        mind that none of your changes will be pushed up to http://musicbrainz.org.

    If you chose RT_SLAVE, please ensure that there is a configuration for
    both READONLY and READWRITE, or the server will not function correctly.
    (Both can be configured the same in a simple setup).


Installing Perl dependencies
----------------------------

The fundamental thing that needs to happen here is all the dependency Perl
modules get installed, somewhere where your server can find them. There are many
ways to make this happen, and the best choice will be very
site-dependent. MusicBrainz ships with support for Carton, a Perl package
manager, which will allow you to have the exact same dependencies as our
production servers. Carton also manages everything for you, and lets you avoid
polluting your system installation with these dependencies.

Below outlines how to setup MusicBrainz server with Carton.


1.  Prerequisites

    Before you get started you will actually need to have Carton installed as
    MusicBrainz does not yet ship with an executable. There are also a few
    development headers that will be needed when installing dependencies. Run
    the following steps as a normal user on your system.

        sudo apt-get install libxml2-dev libpq-dev libexpat1-dev libdb-dev memcached
        sudo cpan Carton

    NOTE: This installs Carton at the system level, if you prefer to install
    this in your home directory, use [local::lib](http://search.cpan.org/perldoc?local::lib).

2.  Install dependencies

    To install the dependencies for MusicBrainz server, first make sure you are
    in the MusicBrainz source code directory and run the following:

        carton install --deployment

    Note that if you've previously used this command in the musicbrainz folder it
    will not always upgrade all packages to their correct version.  If you're
    having trouble running musicbrainz, run "rm -rf local" in the musicbrainz
    directory to remove all packages previously installed by carton, and then run
    the above step again.

    If carton complains about a missing "cpanfile", you can create it with:

        cat Makefile.PL | grep ^requires > cpanfile


    If you still see errors, you can install individual packages manually by running:

        carton install {module name}

    Where {module name} is something like Function::Parameters or Locale::TextDomain.


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

    Note: If you are using Ubuntu 11.10, the collate extension currently does
    not work with gcc 4.6 and needs to be built with an older version such as
    gcc 4.4. To do this, run the following:

        sudo apt-get install gcc-4.4
        cd postgresql-musicbrainz-collate
        CC=gcc-4.4 make -e
        sudo make install
        cd ..


2.  Setup PostgreSQL authentication

    For normal operation, the server only needs to connect from one or two OS
    users (whoever your web server / crontabs run as), to one database (the
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


3.  Create the database

    You have two options when it comes to the database. You can either opt for a
    clean database with just the schema (useful for developers with limited disk
    space), or you can import a full database dump.

    1.  Use a clean database

        To use a clean database, all you need to do is run:

            carton exec ./admin/InitDb.pl -- --createdb --clean

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
            gpg --verify-files /tmp/dump/*.gpg

        If this is OK and you wish to continue, you can import them with:

            carton exec ./admin/InitDb.pl -- --createdb --import /tmp/dumps/mbdump*.tar.bz2 --echo

        `--echo` just gives us a bit more feedback in case this goes wrong, you
        may leave it off. Remember to change the paths to your mbdump*.tar.bz2
        files, if they are not in /tmp/dumps/.


    NOTE: on a fresh postgresql install you may see the following error:

        CreateFunctions.sql:33: ERROR:  language "plpgsql" does not exist

    To resolve that login to postgresql with the "postgres" user (or any other
    postgresql user with SUPERUSER privileges) and load the "plpgsql" language
    into the database with the following command:

        postgres=# CREATE LANGUAGE plpgsql;


Starting the server
------------------

You should now have everything ready to run the development server!

The development server is a lightweight HTTP server that gives good debug
output and is much more convenient than having to set up a standalone
server. Just run:

    carton exec -- plackup -Ilib -r

Visiting http://your.machines.ip.address:5000 should now present you with
your own running instance of the MusicBrainz Server.

If you'd like a more permanent setup, 
[the plackup documentation](https://metacpan.org/module/plackup) may prove
useful in setting up a server such as nginx, using FastCGI.

Translations
------------

If you intend to run a server with translations, there are a few steps to follow:

1. Prerequisites

   Make sure gettext is installed (you need msgmerge and msgfmt, at least),
   and the transifex client 'tx' 
   (http://help.transifex.com/features/client/index.html):

         sudo apt-get install gettext transifex-client

   Configure a username and password in ~/.transifexrc using the format listed 
   on the above page.

2. Change to the po directory

         cd po/

3. Get translations

         tx pull -l {a list of languages you want to pull}

   This will download the .po files for your language(s) of choice to the po/ 
   folder with the correct filenames.

4. Install translations

         make install

   This will compile and install the files to 
   lib/LocaleData/{language}/LC\_MESSAGES/{domain}.mo

5. Add the languages to MB\_LANGUAGES in DBDefs.pm. These should be formatted
   {lang}-{country}, e.g. 'es', or 'fr-ca', in a space-separated list.

6. Ensure you have a system locale for any languages you want to use, and for
   some languages, be wary of https://rt.cpan.org/Public/Bug/Display.html?id=78341

   For many languages, this will suffice: 

         sudo apt-get install language-pack-{language code}

   To work around the linked CPAN bug, you may need to edit the file for Locale::Util
   (if you've installed with carton, local/lib/perl5/Locale/Util.pm) to add entries
   to LANG2COUNTRY. Suggested ones include: 
   * es => 'ES'
   * et => 'EE'
   * el => 'GR'
   * sl => 'SI' (this one is there in 1.20, but needs amendment)

Troubleshooting
---------------

If you have any difficulties, please feel free to contact ocharles or warp
in #musicbrainz-devel on irc.freenode.net, or email the developer mailing
list at musicbrainz-devel [at] lists.musicbrainz.org.

Please report any issues on our [bug tracker](http://tickets.musicbrainz.org).

Good luck, and happy hacking!
