
Introduction
============

This file contains instructions for setting up a local version of the
coverartarchive.org service.  The coverartarchive.org service consists
of several parts:

1. The MusicBrainz server (this allows image uploads)
2. CAA-indexer (updates image metadata on the archive.org servers)
3. coverart_redirect (image redirect service)
4. internet archive S3 storage

The following instructions assume you are running Ubuntu 12.04.


Storage
=======

For development we need a place to store the images, obviously a
development server should not upload images to the actual
coverartarchive storage.

We provide a simple Plack script which emulates just enough of the
internet archive S3 protocol to use it with the musicbrainz server.

It is not designed to server back those static files however, so for
now you will also need to be running a regular webserver (apache,
nginx, etc..).

Figure out where you want to store uploaded images and make sure the
storage server (ssssss.psgi) has write permissions at that location.
E.g. if you have default debian apache install you could do something
like this:

    $ sudo mkdir /var/www/caa
    $ sudo chown user.users /var/www/caa
    $ SSSSSS_STORAGE=/var/www/caa/ plackup --port 5050 -r contrib/ssssss.psgi

Note that we're specifying a port here.  We need the default port
(5000) for musicbrainz.

Now that you're running this script, mb_server should be able to
upload images and indexes to http://localhost/caa/$BUCKET, where
$BUCKET is the bucket name.


CAA-indexer
===========

Download the CAA-indexer and get skytools:

    $ git clone git://github.com/metabrainz/CAA-indexer.git
    $ sudo apt-get install skytools

Set up a configuration file for pgqadm:

    $ cp musicbrainz.ini.example musicbrainz.ini
    $ vim musicbrainz.ini

Make sure to configure a database user with sufficient permission
(otherwise you will probably get a "permission denied for language c"
error from pgqadmin).

The .ini file by default stores log and pid files in /var/log, you
probably do not want this for a development setup.  I would suggest
keeping those in a "log" directory inside the CAA-indexer directory.

Now install PGQ in the database and run the ticker:

    $ pgqadm musicbrainz.ini install
    $ pgqadm musicbrainz.ini ticker -d

Install the triggers into the database:

    $ cd ../musicbrainz-server/
    $ carton exec -- ./admin/psql READWRITE < ./admin/sql/caa/CreatePGQ.sql
    $ cd -

Install the dependancies for the CAA-indexer and create a
configuration file for the CAA-indexer itself:

    $ carton install
    $ cp config.ini.example config.ini
    $ vim config.ini

FIXME: Currently there is no way to configure the server where indexes
should be uploaded to.  We will have to hardcode the correct URL in the
source, edit lib/CoverArtArchive/IAS3Request.pm and change line 21.

    -    my $uri = "$protocol://$1.s3.us.archive.org$2";
    +    my $uri = "$protocol://localhost/caa/$1?file=$2";

And finally run the indexer:

    $ carton exec -Ilib -- ./caa-indexer


coverart_redirect
=================

Download the coverart redirect service and install its dependancies:

    $ git clone git://github.com/metabrainz/coverart_redirect.git
    $ sudo apt-get install python-cherrypy3 python-psycopg2 python-sqlalchemy python-werkzeug

Create a configuration file:

    $ cp coverart_redirect.conf.dist coverart_redirect.conf
    $ vim coverart_redirect.conf

Set prefix=http://localhost/caa/ in the [s3] section (this should be
the location where ssssss.psgi is storing uploaded images).

And start the server:

    $ python ./coverart_redirect_server.py


MusicBrainz Server
==================

Now that all of that is configured you can point the musicbrainz server at
the upload and download urls for your local cover art archive, change
the following values in lib/DBDefs.pm:

    sub COVER_ART_ARCHIVE_UPLOAD_PREFIXER { sprintf("http://localhost:5050/%s", shift) };
    sub COVER_ART_ARCHIVE_DOWNLOAD_PREFIX { "http://localhost:8080" };
