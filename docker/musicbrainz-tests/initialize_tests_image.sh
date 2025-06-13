#!/usr/bin/env bash

set -e -x

cd "$MBS_ROOT"

. docker/musicbrainz-tests/sv_start_if_down.sh

sudo -E -H -u musicbrainz mkdir -p junit_output

sudo -E -H -u musicbrainz cp docker/musicbrainz-tests/DBDefs.pm lib/

sv_start_if_down \
    postgresql \
    redis # script/dump_js_type_info.pl needs Redis running.

sudo -E -H -u musicbrainz carton exec -- ./script/create_test_db.sh

cd /var/lib/postgresql

# Create clones of the musicbrainz_test DB used by various tests.
sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_selenium
sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_json_dump
sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_full_export
sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_sitemaps

cd /home/musicbrainz/sir

# Generate and install the sir triggers into musicbrainz_selenium.
sudo -E -H -u musicbrainz sh -c '. venv/bin/activate; python -m sir extension; python -m sir triggers --broker-id=1'

psql -U postgres -f sql/CreateExtension.sql musicbrainz_selenium
psql -U musicbrainz -f sql/CreateFunctions.sql musicbrainz_selenium
psql -U musicbrainz -f sql/CreateTriggers.sql musicbrainz_selenium

cd /home/musicbrainz/artwork-indexer

# Install the artwork_indexer schema into musicbrainz_selenium.
sudo -E -H -u musicbrainz sh -c '. venv/bin/activate; python indexer.py --setup-schema'

cd "$MBS_ROOT"

sudo -E -H -u musicbrainz make -C po all_quiet deploy

# Compile static resources.
NODE_ENV=test \
    WEBPACK_MODE=development \
    MUSICBRAINZ_RUNNING_TESTS=1 \
    NO_CACHE=1 \
    NO_PROGRESS=1 \
    NO_YARN=1 \
    sudo -E -H -u musicbrainz carton exec -- ./script/compile_resources.sh default tests
