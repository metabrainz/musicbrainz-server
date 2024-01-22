
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

To simulate a 503 Slow Down error, run slowdown.psgi instead of ssssss.psgi:

    $ plackup --port 5050 contrib/slowdown.psgi


CAA-indexer
===========

Download the CAA-indexer and install RabbitMQ.

    $ git clone git://github.com/metabrainz/CAA-indexer.git
    $ sudo apt-get install rabbitmq
    $ sudo /etc/init.d/rabbitmq start

You will also need to install the `pg_amqp` extension for PostgreSQL. For
details on this, see https://github.com/omniti-labs/pg_amqp, but it can
generally be described as:

    $ git clone https://github.com/omniti-labs/pg_amqp.git
    $ cd pg_amqp
    $ sudo make install

And then editing `postgresql.conf` to have:

    shared_preload_libraries = 'pg_amqp.so'

Restart postgresql for the changes in `postgresql.conf` to take effect.

Install the triggers into the database:

    $ cd ../musicbrainz-server/
    $ ./admin/psql READWRITE < ./admin/sql/caa/CreateMQTriggers.sql
    $ cd -

Install the dependencies for the CAA-indexer and create a
configuration file for the CAA-indexer itself:

    $ cpanm --installdeps --notest .
    $ cp config.ini.example config.ini
    $ vim config.ini

Configure where indexes should be uploaded to by changing `upload_url`:

    upload_url = //localhost/caa/{bucket}?file={file}

And finally run the indexer:

    $ ./caa-indexer


coverart_redirect
=================

Download the coverart redirect service and install its dependencies:

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

    sub INTERNET_ARCHIVE_UPLOAD_PREFIXER { shift; sprintf("//localhost:5050/%s", shift) }
    sub COVER_ART_ARCHIVE_DOWNLOAD_PREFIX { "http://localhost:8080" }
    sub EVENT_ART_ARCHIVE_DOWNLOAD_PREFIX { "http://localhost:8080" }
