#!/bin/bash

pushd /root/musicbrainz-server
carton exec -- ./script/create_test_db.sh
popd
