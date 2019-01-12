#!/bin/bash

set -e

PGDATA=/var/lib/postgresql/10/main

cd /home/musicbrainz/musicbrainz-server
if [[ "$MB_IMPORT_DUMPS" = "true" && ! -f "$PGDATA/.mb_db_imported" ]]; then
    sudo -E -H -u musicbrainz carton exec -- ./docker/scripts/import_db.sh
    sudo -E -H -u postgres touch "$PGDATA/.mb_db_imported"
fi

exec sudo -E -H -u postgres \
    /usr/lib/postgresql/10/bin/postgres -D "$PGDATA"
