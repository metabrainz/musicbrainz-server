#!/bin/bash

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
GIT_MSG=$(git log -1 --format=format:"Last commit by %an on %ad: %s" --date=short)
GIT_SHA=$(git log -1 --format=format:"%h")

NAME=$1
DOCKERFILE=Dockerfile.$NAME
m4 -D GIT_INFO="$GIT_BRANCH:$GIT_SHA:$GIT_MSG" -I templates -P templates/$DOCKERFILE.m4 > $DOCKERFILE

TAG=metabrainz/musicbrainz-$NAME:$GIT_BRANCH
docker build --tag $TAG --file $DOCKERFILE ../
docker push $TAG
