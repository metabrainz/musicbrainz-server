#!/bin/bash

set -e
shopt -s failglob

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

BUILD_DIR=${MBS_STATIC_BUILD_DIR:-root/static/build/}
mkdir -p "$BUILD_DIR"

pushd root/static/images/leaflet/ > /dev/null
ln -sf ../../../../node_modules/leaflet/dist/images/*.png .
# Remove broken symlinks. These can exist because of MBS-9264, or because
# Leaflet removed an image in an update.
find . -type l ! -exec test -e '{}' \; -exec rm '{}' \;
popd > /dev/null

./script/dbdefs_to_js.pl --client

./node_modules/.bin/gulp $@

./script/dbdefs_to_js.pl
