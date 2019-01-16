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

sudo -E -H -u musicbrainz \
    carton exec -- ./script/dump_js_type_info.pl

sudo -E -H -u musicbrainz \
    carton exec -- ./script/compile_resources.sh web-tests

exec sudo -E -H -u musicbrainz carton exec -- prove \
    --pgtap-option dbname=musicbrainz_test \
    --pgtap-option host=musicbrainz-test-database \
    --pgtap-option port=5432 \
    --pgtap-option username=musicbrainz \
    --source Perl \
    --source pgTAP \
    -I lib \
    -j 2 \
    t/flow.sh \
    t/js.t \
    t/web.js \
    t/selenium.js \
    t/pgtap/* \
    t/pgtap/unused-tags/* \
    t/script/*.t \
    t/tests.t \
    --harness=TAP::Harness::JUnit \
    -v
