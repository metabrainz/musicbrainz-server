#!/bin/bash

source /etc/mbs_constants.sh

cd "$MBS_ROOT"

while true; do
    chpst -u musicbrainz:musicbrainz \
        carton exec -- ./script/database_exists SYSTEM > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        break
    else
        echo "Waiting for database to start..."
        sleep 5
    fi
done

(exec runsvdir /etc/service &>/dev/null &)

exec sudo -E -H -u musicbrainz carton exec -- prove \
    --pgtap-option dbname=musicbrainz_test \
    --pgtap-option host=musicbrainz-test-database \
    --pgtap-option port=5432 \
    --pgtap-option username=musicbrainz \
    --source Perl \
    --source pgTAP \
    -I lib \
    t/critic.t \
    t/js.t \
    t/web.js \
    t/selenium.js \
    t/create_test_db.t \
    t/pgtap/* \
    t/pgtap/unused-tags/* \
    t/script/*.t \
    t/tests.t \
    --harness=TAP::Harness::JUnit \
    -v
