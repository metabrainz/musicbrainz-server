#!/bin/bash

pushd /home/musicbrainz/musicbrainz-server
# gosu comes with the postgres:9.5 image.
gosu musicbrainz:musicbrainz carton exec -- ./script/create_test_db.sh
popd
