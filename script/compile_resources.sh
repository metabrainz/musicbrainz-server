#!/bin/bash

set -e
shopt -s failglob

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

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

./script/dbdefs_to_js.pl

BUILD_CLIENT=0
BUILD_SERVER=0
BUILD_TESTS=0

if [[ "$#" == "0" ]]; then
    BUILD_CLIENT=1
    BUILD_SERVER=1
else
    while (( "$#" )); do
        case "$1" in
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
            *)
                echo $"Usage: $0 {default|client|server|tests}"
                exit 1
        esac
        shift
    done
fi

if [[ "$BUILD_CLIENT" == "1" ]]; then
    ./node_modules/.bin/webpack --config webpack.client.config.js &
    trap_jobs
fi

if [[ "$BUILD_SERVER" == "1" ]]; then
    ./node_modules/.bin/webpack --config webpack.server.config.js &
    trap_jobs
fi

if [[ "$BUILD_TESTS" == "1" ]]; then
    if ./script/database_exists TEST 2> /dev/null; then
        ./script/dump_js_type_info.pl
    else
        echo 'Skipping typeInfo.js dump; no running TEST database?'
    fi
    ./node_modules/.bin/webpack --config webpack.tests.config.js &
    trap_jobs
fi
