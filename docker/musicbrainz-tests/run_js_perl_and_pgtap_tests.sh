#!/usr/bin/env bash

set -e -o pipefail -x

function sv_start_if_down() {
  while [[ $# -gt 0 ]]
  do
    if [[ -e "/etc/service/$1/down" ]]
    then
      rm -fv "/etc/service/$1/down"
      sv -w 30 start "$1"
    fi
    shift
  done
}

cd "$MBS_ROOT"

sudo -E -H -u musicbrainz make -C po test_source

echo Checking JavaScript code’s static types with Flow
sudo -E -H -u musicbrainz ./node_modules/.bin/flow --quiet
echo OK

echo Checking JavaScript code’s quality and style with ESLint
sudo -E -H -u musicbrainz ./node_modules/.bin/eslint --max-warnings 0 .
echo OK

echo Checking translation domain in statistics code
sudo -E -H -u musicbrainz \
    git --no-pager grep -Pw '(N_)?l[np]?\(' -- 'root/statistics/**.js' \
    && { exit 1; }
echo OK

# GitHub Actions overrides the container entrypoint.
/sbin/my_init &
sleep 5

sv_start_if_down chrome postgresql redis

sudo -E -H -u musicbrainz carton exec -- ./bin/sucrase-node \
    t/web.js \
    | tee >(./node_modules/.bin/tap-junit > ./junit_output/js_web.xml) \
    | ./node_modules/.bin/tap-difflet

sv kill chrome

./docker/musicbrainz-tests/add_mbtest_alias.sh

sv_start_if_down template-renderer vnu website

export MMD_SCHEMA_ROOT=/home/musicbrainz/mmd-schema
export JUNIT_OUTPUT_FILE=junit_output/perl_and_pgtap.xml

prove_exit_code=0
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
    t/script/UpdateDatabasePrivileges.t \
    t/tests.t \
    --harness=TAP::Harness::JUnit \
    -v || { prove_exit_code=$?; true; }

# Stop the template-renderer so that it dumps coverage.
sv down template-renderer
sleep 10

if [ "$GITHUB_ACTIONS" = 'true' ]; then
  if [[ -d .nyc_output && $(ls -A .nyc_output) ]]; then
      cp -Ra .nyc_output "$GITHUB_WORKSPACE"/nyc_output
  fi
  if [ -d junit_output ]; then
    cp -Ra junit_output "$GITHUB_WORKSPACE"
  fi
fi

exit $prove_exit_code
