#!/usr/bin/env bash

set -e

if [ $# -ne 0 ] && \
    (
        [ $# -gt 3 ] || \
        ( [ $# -ge 1 ] && [[ "${1##*/}" != "cpanfile" ]] ) || \
        ( [ $# -ge 2 ] && [[ "${2##*/}" != Dockerfile* ]] ) || \
        ( [ $# -eq 3 ] && [[ "${3##*/}" != cpanfile*.snapshot ]] )
    )
then
    echo "Usage: $0 [path/to/cpanfile] [path/to/Dockerfile] [path/to/cpanfile.snapshot]"
    exit 1
fi

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

function abs_path {
    echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

CPANFILE="$(abs_path "${1:-$MB_SERVER_ROOT/cpanfile}")"
DOCKERFILE="$(abs_path "${2:-$MB_SERVER_ROOT/docker/Dockerfile.cpanfile-snapshot}")"
CPANFILE_SNAPSHOT="$(abs_path "${3:-$MB_SERVER_ROOT/cpanfile.snapshot}")"

export DOCKER_CMD=${DOCKER_CMD:-docker}

make -C docker config

TMP_IMG=mbs_generate_cpanfile_snapshot
TMP_DIR=/tmp/.$TMP_IMG

mkdir -p "$TMP_DIR/docker"
cd "$TMP_DIR"

cp "$MB_SERVER_ROOT/docker/pgdg_pubkey.txt" "$TMP_DIR/docker/"
cp "$CPANFILE" "$TMP_DIR/"
cp "$DOCKERFILE" "$TMP_DIR/Dockerfile"

$DOCKER_CMD build -t $TMP_IMG .
CONTAINER_ID=$($DOCKER_CMD create $TMP_IMG)
$DOCKER_CMD cp \
    $CONTAINER_ID:/home/musicbrainz/musicbrainz-server/cpanfile.snapshot \
    "$CPANFILE_SNAPSHOT"
$DOCKER_CMD rm $CONTAINER_ID
$DOCKER_CMD rmi $TMP_IMG

rm -rf "$TMP_DIR"
