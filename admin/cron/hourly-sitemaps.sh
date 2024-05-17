#!/usr/bin/env bash

set -u
set -e

if [[ -t 1 ]]
then
    exec 2>&1 | ts '%X %Z'
fi

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

. ./admin/functions.sh
make_temp_dir

FK_DUMP="$TEMP_DIR"/foreign_keys
./script/dump_foreign_keys.pl \
    --database READONLY \
    --output "$FK_DUMP"

./admin/BuildIncrementalSitemaps.pl \
    --database READWRITE \
    --foreign-keys-dump "$FK_DUMP" \
    --ping

cleanup() { rm -f "$FK_DUMP"; }
trap cleanup EXIT

./bin/rsync-sitemaps
