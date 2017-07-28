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

./node_modules/.bin/gulp "$@" &
trap_jobs
