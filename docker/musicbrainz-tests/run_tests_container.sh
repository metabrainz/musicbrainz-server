#!/usr/bin/env bash

CONTAINER_NAME="$1"
TESTS_IMAGE_TAG="$2"

MBS_ROOT=/home/musicbrainz/musicbrainz-server

docker run \
    --detach \
    --user root \
    --workdir "$MBS_ROOT" \
    --volume "$(pwd)":/workspace \
    --env CI=true \
    --env GITHUB_ACTIONS=true \
    --env GITHUB_WORKSPACE=/workspace \
    --name "$CONTAINER_NAME" \
    metabrainz/musicbrainz-tests:"$TESTS_IMAGE_TAG"

docker cp mbs_checkout/. "$CONTAINER_NAME":"$MBS_ROOT"
docker exec "$CONTAINER_NAME" sh -c "cd $MBS_ROOT; chown -R musicbrainz:musicbrainz ."
