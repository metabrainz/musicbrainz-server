#!/usr/bin/env bash

set -e

if [ $# -ne 0 -a "(" $# -ne 1 -o "${1##*/}" != "cpanfile" ")" ]; then
    echo "Usage: $0 [path/to/cpanfile]"
    exit 1
fi

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
CPANFILE_DIR=$(cd "$(dirname ${1:-$MB_SERVER_ROOT/cpanfile})/" && pwd)
cd "$MB_SERVER_ROOT"

export DOCKER_CMD=${DOCKER_CMD:-docker}

make -C docker config

TMP_IMG=mbs_generate_cpanfile_snapshot
TMP_DIR=/tmp/.$TMP_IMG

mkdir -p "$TMP_DIR/docker"
cd "$TMP_DIR"

cp "$MB_SERVER_ROOT/docker/pgdg_pubkey.txt" "$TMP_DIR/docker/"
cp "$CPANFILE_DIR/cpanfile" "$TMP_DIR/"
cp "$MB_SERVER_ROOT/docker/Dockerfile.cpanfile-snapshot" "$TMP_DIR/Dockerfile"

$DOCKER_CMD build -t $TMP_IMG .
CONTAINER_ID=$($DOCKER_CMD create $TMP_IMG)
$DOCKER_CMD cp \
    $CONTAINER_ID:/home/musicbrainz/musicbrainz-server/cpanfile.snapshot \
    "$CPANFILE_DIR/"
$DOCKER_CMD rm $CONTAINER_ID
$DOCKER_CMD rmi $TMP_IMG

rm -rf "$TMP_DIR"
