#!/bin/bash

set -e

SRC_IMG=${1:-master}

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

make -C docker config

TMP_IMG=mbs_generate_cpanfile_snapshot
TMP_DIR=/tmp/.$TMP_IMG

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

cp "$MB_SERVER_ROOT/cpanfile" "$TMP_DIR/"
cp "$MB_SERVER_ROOT/docker/Dockerfile.cpanfile-snapshot" "$TMP_DIR/Dockerfile"

CONTAINER_ID=$(docker create metabrainz/musicbrainz-website:$SRC_IMG)
docker cp $CONTAINER_ID:/home/musicbrainz/carton-local .
docker rm $CONTAINER_ID

docker build -t $TMP_IMG .
CONTAINER_ID=$(docker create $TMP_IMG)
docker cp \
    $CONTAINER_ID:/home/musicbrainz/musicbrainz-server/cpanfile.snapshot \
    "$MB_SERVER_ROOT/"
docker rm $CONTAINER_ID
docker rmi $TMP_IMG

rm -rf "$TMP_DIR"
