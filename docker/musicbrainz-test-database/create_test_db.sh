#!/usr/bin/env bash

pg_ctl -o "-c listen_addresses='localhost'" -w restart
cd /home/musicbrainz/musicbrainz-server
if [ "$MB_IMPORT_DUMPS" = "true" ]; then
    carton exec -- ./docker/scripts/import_db.sh
else
    carton exec -- ./script/create_test_db.sh
fi
