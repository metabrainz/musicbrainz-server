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

clone_test_db() {
    sudo -E -H -u musicbrainz \
        createdb \
            -O musicbrainz \
            -T musicbrainz_test \
            -U postgres \
            -h musicbrainz-test-database \
            -p 5432 \
            "$1"
}

clone_test_db 'musicbrainz_test_json_dump'
clone_test_db 'musicbrainz_test_full_export'
clone_test_db 'musicbrainz_test_sitemaps'
clone_test_db 'musicbrainz_test_template'

exec sudo -E -H -u musicbrainz carton exec -- prove \
    --pgtap-option dbname=musicbrainz_test \
    --pgtap-option host=musicbrainz-test-database \
    --pgtap-option port=5432 \
    --pgtap-option username=musicbrainz \
    --source Perl \
    --source pgTAP \
    -I lib \
    -j 9 \
    t/flow.sh \
    t/js.t \
    t/web.js \
    t/selenium.js \
    t/pgtap/* \
    t/pgtap/unused-tags/* \
    t/script/BuildSitemaps.t \
    t/script/DumpJSON.t \
    t/script/ExportAllTables.t \
    t/tests.t \
    --harness=TAP::Harness::JUnit \
    -v
