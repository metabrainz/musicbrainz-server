#!/bin/sh

# These are installed and created properly in the CircleCI build job,
# but lost in subsequent jobs due to /usr/lib/* being outside our
# workspace root (which is /home/musicbrainz). We can simply reinstall
# them, which is what this script does.

cd /home/musicbrainz/musicbrainz-server
cd postgresql-musicbrainz-collate && make install && cd -
cd postgresql-musicbrainz-unaccent && make install && cd -
