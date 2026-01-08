#!/usr/bin/env bash

set -e -x

cd "$MBS_ROOT"

. docker/musicbrainz-tests/sv_start_if_down.sh

sudo -E -H -u musicbrainz mkdir -p junit_output

sudo -E -H -u musicbrainz cp docker/musicbrainz-tests/DBDefs.pm lib/

sv_start_if_down \
    postgresql \
    redis # script/dump_js_type_info.pl needs Redis running.

REPLICATION_TYPE=1 \
    sudo -E -H -u musicbrainz carton exec -- ./script/create_test_db.sh

cd /var/lib/postgresql

# Create clones of the musicbrainz_test DB used by various tests.
sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_selenium
sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_json_dump
sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_full_export
sudo -E -H -u postgres createdb -O musicbrainz -T musicbrainz_test -U postgres musicbrainz_test_sitemaps

cd /home/musicbrainz/sir

# Generate the sir extensions and triggers, which is required before
# invoking create_selenium_db.sh.
sudo -E -H -u musicbrainz sh -c '. venv/bin/activate; python -m sir extension; python -m sir triggers --broker-id=1'

cd "$MBS_ROOT"

# Run msgmerge on all .po flies to ensure string locations are up-to-date.
shopt -s nullglob
for pot in po/*.pot; do
  domain="$(basename "$pot" .pot)"
  for po in po/"$domain".*.po; do
    sudo -E -H -u musicbrainz \
      msgmerge --no-fuzzy-matching --update "$po" po/"$domain".pot || true
  done
done

sudo -E -H -u musicbrainz make -C po all_quiet deploy

# Compile static resources.
NODE_ENV=test \
    WEBPACK_MODE=development \
    MUSICBRAINZ_RUNNING_TESTS=1 \
    NO_CACHE=1 \
    NO_PROGRESS=1 \
    NO_YARN=1 \
    sudo -E -H -u musicbrainz carton exec -- ./script/compile_resources.sh default tests
