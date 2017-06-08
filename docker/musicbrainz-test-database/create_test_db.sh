#!/bin/bash

cd /home/musicbrainz/musicbrainz-server
if $MB_IMPORT_DUMPS; then
    carton exec -- ./docker/scripts/import_db.sh
else
    carton exec -- ./script/create_test_db.sh
fi
