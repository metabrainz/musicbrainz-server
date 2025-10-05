Introduction
============

This file contains instructions for setting up a local version of the
coverartarchive.org and eventartarchive.org services. These services
consist of several parts:

1. MusicBrainz Server (this allows image uploads)
2. artwork-indexer (updates image metadata on the archive.org servers)
3. artwork-redirect (image redirect service)
4. Internet Archive S3 storage


Storage
=======

For development we need a place to store the images. Obviously, a
development server should not upload images to the actual
Internet Archive storage.

We provide a simple Plack script which emulates just enough of the
Internet Archive S3 protocol to use it with MusicBrainz Server.

Figure out where you want to store uploaded images, and set the
`SSSSSS_STORAGE` environment variable to that location:

    $ SSSSSS_STORAGE=./ssssss plackup --port 5050 -r contrib/ssssss.psgi

Note that we're specifying a port here.  We need the default port
(5000) for MusicBrainz Server.

Now that you're running this script, MusicBrainz Server should be able to
upload images and indexes to `http://localhost:5050/$BUCKET`, where
`$BUCKET` is the bucket name.

To simulate a 503 Slow Down error, run slowdown.psgi instead of ssssss.psgi:

    $ plackup --port 5050 contrib/slowdown.psgi


artwork-indexer
===============

Download and setup the artwork-indexer.

    $ git clone https://github.com/metabrainz/artwork-indexer.git

Follow the [installation instructions in the README](https://github.com/metabrainz/artwork-indexer?tab=readme-ov-file#installation).

Edit config.ini with values suitable for your setup. Here's a very standard
example:

```ini
[musicbrainz]
# Set to the host:port plackup is listening on.
url=http://localhost:5000
database=READWRITE

[database]
host=localhost
port=5432
user=musicbrainz
dbname=musicbrainz_db

[s3]
# Set to the host:port ssssss.psgi is listening on.
url=http://localhost:5050/{bucket}?file={file}
caa_access=caa_user
caa_secret=caa_pass
eaa_access=eaa_user
eaa_secret=eaa_pass

[sentry]
dsn=
```

Finally, start the indexer:

    $ poetry run python indexer.py


artwork-redirect
================

Download and setup the artwork-redirect service:

    $ git clone https://github.com/metabrainz/artwork-redirect.git

Follow the [installation instructions in the README](https://github.com/metabrainz/artwork-redirect?tab=readme-ov-file#option-2-manual).

Edit config.ini based on the following example:

```ini
[database]
host=localhost
port=5432
user=musicbrainz
database=musicbrainz_db

[listen]
address=localhost
port=8080

[ia]
# Set to the host:port ssssss.psgi is listening on. Image/index requests
# will be redirect here.
download_prefix=http://localhost:5050

[sentry]
dsn=
```

And start the server (with your virtualenv active):

    (.venv) $ python artwork_redirect_server.py


MusicBrainz Server
==================

Now that all of that is configured, you can point MusicBrainz Server to
the upload and download URLs for your local image archive. Change
the following values in lib/DBDefs.pm:

```Perl
# Set to the host:port ssssss.psgi is listening on.
sub INTERNET_ARCHIVE_UPLOAD_PREFIXER { shift; sprintf("//localhost:5050/%s", shift) }

# Set to the host:port artwork-redirect is listening on.
sub COVER_ART_ARCHIVE_DOWNLOAD_PREFIX { "http://localhost:8080" }
sub EVENT_ART_ARCHIVE_DOWNLOAD_PREFIX { "http://localhost:8080" }

sub INTERNET_ARCHIVE_IA_DOWNLOAD_PREFIX { '' }
# Set to the host:port ssssss.psgi is listening on.
sub INTERNET_ARCHIVE_IA_METADATA_PREFIX { 'http://localhost:5050/metadata' }

# Must match the configured values for `caa_access`, `caa_secret`,
# `eaa_access`, and `eaa_secret` under the `[s3]` section of your
# artwork-indexer config.ini.
sub COVER_ART_ARCHIVE_ACCESS_KEY { 'caa_user' }
sub COVER_ART_ARCHIVE_SECRET_KEY { 'caa_pass' }
sub EVENT_ART_ARCHIVE_ACCESS_KEY { 'eaa_user' }
sub EVENT_ART_ARCHIVE_SECRET_KEY { 'eaa_pass' }
```
