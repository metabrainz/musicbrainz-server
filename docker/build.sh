#!/bin/bash

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)

NAME=$1
DOCKERFILE=Dockerfile.$NAME
m4 -I templates -P templates/$DOCKERFILE.m4 > $DOCKERFILE

TAG=metabrainz/musicbrainz-$NAME:$GIT_BRANCH
docker build --tag $TAG --file $DOCKERFILE .
docker push $TAG
