#!/bin/bash

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

BUILD_DIR=${MBS_STATIC_BUILD_DIR:-root/static/build/}
mkdir -p "$BUILD_DIR"

# Remove the symbolic link first. Since it points to a directory, we'd
# otherwise need to pass the no-dereference flag to ln, but the name of that
# flag differs between GNU coreutils and BSD/macOS.
rm -f ./root/static/images/leaflet
ln -s ../../../node_modules/leaflet/dist/images \
    ./root/static/images/leaflet

./script/dbdefs_to_js.pl --client

./node_modules/.bin/gulp $@

./script/dbdefs_to_js.pl
