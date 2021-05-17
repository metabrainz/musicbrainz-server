#!/usr/bin/env bash

set -e
shopt -s failglob

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

yarn

source script/functions.sh

BUILD_DIR=${MBS_STATIC_BUILD_DIR:-root/static/build/}
mkdir -p "$BUILD_DIR"

pushd root/static/images/leaflet/ > /dev/null
ln -sf ../../../../node_modules/leaflet/dist/images/*.png .
# Remove broken symlinks. These can exist because of MBS-9264, or because
# Leaflet removed an image in an update.
find . -type l ! -exec test -e '{}' \; -exec rm '{}' \;
popd > /dev/null

if [ -z "$GIT_BRANCH" ]; then
    export GIT_BRANCH=$(./script/git_info branch)
fi

if [ -z "$GIT_SHA" ]; then
    export GIT_SHA=$(./script/git_info sha)
fi

# lib/DBDefs.pm doesn't exist when building Docker images.
# In production, dbdefs_to_js.pl is run by consul-template once
# DBDefs.pm is rendered.
if [ -f lib/DBDefs.pm ]; then
    ./script/dbdefs_to_js.pl
fi

BUILD_CLIENT=0
BUILD_SERVER=0
BUILD_TESTS=0
WATCH_MODE=0
JOBS_TRAPPED=0

check_trap_jobs() {
    if [[ "$JOBS_TRAPPED" == "0" ]]; then
        trap_jobs_nowait
        JOBS_TRAPPED=1
    fi
    # For watch mode, we only want to wait once at the end.
    if [[ "$WATCH_MODE" == "0" ]]; then wait; fi
}

# Handle the default case when --watch is the only argument provided.
if [[ "$#" == 1 && "$1" == '--watch' ]]; then export WATCH_MODE=1; fi

if [[ "$#" == "0" || "$WATCH_MODE" == "1" ]]; then
    BUILD_CLIENT=1
    BUILD_SERVER=1
else
    while (( "$#" )); do
        case "$1" in
            --watch)
                export WATCH_MODE=1
                ;;
            default)
                BUILD_CLIENT=1
                BUILD_SERVER=1
                ;;
            client)
                BUILD_CLIENT=1
                ;;
            server)
                BUILD_SERVER=1
                ;;
            tests)
                BUILD_TESTS=1
                ;;
            web-tests) # for backwards-compat. only
                BUILD_TESTS=1
                ;;
            *)
                echo $"Usage: $0 [--watch] {default|client|server|tests}"
                exit 1
        esac
        shift
    done
fi

REV_MANIFEST="$BUILD_DIR/rev-manifest.json"

if [[ "$BUILD_CLIENT" == "1" ]]; then
    ./node_modules/.bin/webpack --config webpack.client.config.js &
    check_trap_jobs

    if [[ "$BUILD_SERVER" == "1" ]]; then
        sleep 5
        while [[ ! -f "$REV_MANIFEST" ]]; do
            echo 'Waiting for rev-manifest.json before building server JS ...'
            sleep 3
        done
    fi
fi

if [[ "$BUILD_SERVER" == "1" ]]; then
    if [[ ! -f "$REV_MANIFEST" ]]; then
        echo '{}' > "$REV_MANIFEST"
    fi
    ./node_modules/.bin/webpack --config webpack.server.config.js &
    check_trap_jobs
fi

if [[ "$BUILD_TESTS" == "1" ]]; then
    if ./script/database_exists TEST 2> /dev/null; then
        ./script/dump_js_type_info.pl
    else
        echo 'Skipping typeInfo.js dump; no running TEST database?'
    fi
    ./node_modules/.bin/webpack --config webpack.tests.config.js &
    check_trap_jobs
fi

if [[ "$WATCH_MODE" == "1" ]]; then wait; fi
