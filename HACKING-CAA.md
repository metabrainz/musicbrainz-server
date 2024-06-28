
Introduction
============

This file contains instructions for setting up a local version of the
coverartarchive.org service.  The coverartarchive.org service consists
of several parts:

1. The MusicBrainz server (this allows image uploads)
2. artwork-indexer (updates image metadata on the archive.org servers)
3. artwork-redirect (image redirect service)
4. internet archive S3 storage


Storage
=======

For development we need a place to store the images, obviously a
development server should not upload images to the actual
coverartarchive storage.

We provide a simple Plack script which emulates just enough of the
internet archive S3 protocol to use it with the musicbrainz server.

Figure out where you want to store uploaded images, and set the
`SSSSSS_STORAGE` environment variable to that location:

    $ SSSSSS_STORAGE=./ssssss plackup --port 5050 -r contrib/ssssss.psgi

Note that we're specifying a port here.  We need the default port
(5000) for musicbrainz.

Now that you're running this script, mb_server should be able to
upload images and indexes to `http://localhost:5050/$BUCKET`, where
`$BUCKET` is the bucket name.

To simulate a 503 Slow Down error, run slowdown.psgi instead of ssssss.psgi:

    $ plackup --port 5050 contrib/slowdown.psgi


artwork-indexer
===============

Download and setup the artwork-indexer.

    $ git clone https://github.com/metabrainz/artwork-indexer.git

Follow the [installation instructions in the README](https://github.com/metabrainz/artwork-indexer?tab=readme-ov-file#installation).

Configure where indexes should be uploaded to by changing `url` under the
`[s3]` section:

    [s3]
    url=http://localhost:5050/{bucket}?file={file}

Also ensure that the configured values for `caa_access`, `caa_secret`,
`eaa_access`, and `eaa_secret` under the `[s3]` section match the
corresponding values in your DBDefs.pm:

    sub COVER_ART_ARCHIVE_ACCESS_KEY { }
    sub COVER_ART_ARCHIVE_SECRET_KEY { }
    sub EVENT_ART_ARCHIVE_ACCESS_KEY { }
    sub EVENT_ART_ARCHIVE_SECRET_KEY { }

It's fine to leave them blank in both config files.

Finally, start the indexer:

    (.venv) $ python indexer.py


artwork-redirect
================

Download and setup the artwork-redirect service:

    $ git clone https://github.com/metabrainz/artwork-redirect.git

Follow the [installation instructions in the README](https://github.com/metabrainz/artwork-redirect?tab=readme-ov-file#option-2-manual).

Configure where indexes and images are redirected to by changing
`download_prefix` under the `[ia]` section:

    [ia]
    download_prefix=http://localhost:5050/

This should be the location where ssssss.psgi is storing uploaded images.

And start the server:

    (.venv) $ python artwork_redirect_server.py


MusicBrainz Server
==================

Now that all of that is configured you can point the musicbrainz server at
the upload and download urls for your local cover art archive, change
the following values in lib/DBDefs.pm:

    sub INTERNET_ARCHIVE_UPLOAD_PREFIXER { shift; sprintf("//localhost:5050/%s", shift) }
    sub COVER_ART_ARCHIVE_DOWNLOAD_PREFIX { "http://localhost:8080" }
    sub EVENT_ART_ARCHIVE_DOWNLOAD_PREFIX { "http://localhost:8080" }
