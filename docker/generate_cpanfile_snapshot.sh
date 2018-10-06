#!/bin/bash

set -e

if [ $# -ne 0 -a "(" $# -ne 1 -o "${1##*/}" != "cpanfile" ")" ]; then
    echo "Usage: $0 [path/to/cpanfile]"
    exit 1
fi

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
CPANFILE_DIR=$(cd "$(dirname ${1:-$MB_SERVER_ROOT/cpanfile})/" && pwd)
cd "$MB_SERVER_ROOT"

make -C docker config

TMP_IMG=mbs_generate_cpanfile_snapshot
TMP_DIR=/tmp/.$TMP_IMG

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

cp "$CPANFILE_DIR/cpanfile" "$TMP_DIR/"
cp "$MB_SERVER_ROOT/docker/Dockerfile.cpanfile-snapshot" "$TMP_DIR/Dockerfile"

docker build -t $TMP_IMG .
CONTAINER_ID=$(docker create $TMP_IMG)
docker cp \
    $CONTAINER_ID:/home/musicbrainz/musicbrainz-server/cpanfile.snapshot \
    "$CPANFILE_DIR/"
docker rm $CONTAINER_ID
docker rmi $TMP_IMG

rm -rf "$TMP_DIR"
