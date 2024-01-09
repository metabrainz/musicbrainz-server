#!/usr/bin/env bash

sudo -E -H -u musicbrainz mkdir -p junit_output

sudo -E -H -u musicbrainz cp docker/musicbrainz-tests/DBDefs.pm lib/

rm /etc/service/{postgresql,redis}/down && sv start postgresql redis

sudo -E -H -u musicbrainz carton exec -- ./script/create_test_db.sh

sudo -E -H -u musicbrainz make -C po test_source all_quiet deploy

MUSICBRAINZ_RUNNING_TESTS=1 \
    NODE_ENV=test \
    WEBPACK_MODE=development \
    NO_PROGRESS=1 \
    sudo -E -H -u musicbrainz \
        carton exec -- ./script/compile_resources.sh client server web-tests

sudo -E -H -u musicbrainz ./node_modules/.bin/flow --quiet
sudo -E -H -u musicbrainz ./node_modules/.bin/eslint --max-warnings 0 .
! git grep -Pw '(N_)?l[np]?\(' -- 'root/statistics/**.js'

rm /etc/service/chrome/down && sv start chrome

sudo -E -H -u musicbrainz carton exec -- node \
    t/web.js \
    | tee >(./node_modules/.bin/tap-junit > ./junit_output/js_web.xml) \
    | ./node_modules/.bin/tap-difflet

sv kill chrome

./docker/musicbrainz-tests/add_mbtest_alias.sh

sudo -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_json_dump
sudo -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_full_export
sudo -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_sitemaps

rm /etc/service/{template-renderer,vnu,website}/down && sv start template-renderer vnu website

export MMD_SCHEMA_ROOT=/home/musicbrainz/mb-solr/mmd-schema
export JUNIT_OUTPUT_FILE=junit_output/perl_and_pgtap.xml

sudo -E -H -u musicbrainz carton exec -- prove \
    --pgtap-option dbname=musicbrainz_test \
    --pgtap-option host=localhost \
    --pgtap-option port=5432 \
    --pgtap-option username=musicbrainz \
    --source pgTAP \
    --source Perl \
    -I lib \
    t/author/* \
    t/critic.t \
    t/hydration_i18n.t \
    t/pgtap/* \
    t/pgtap/unused-tags/* \
    t/script/MergeDuplicateArtistCredits.t \
    t/script/BuildSitemaps.t \
    t/script/DumpJSON.t \
    t/script/ExportAllTables.t \
    t/script/dbmirror2.t \
    t/tests.t \
    --harness=TAP::Harness::JUnit \
    -v
