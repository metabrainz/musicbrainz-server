#!/bin/bash

set -e

MBS_HOME=/home/musicbrainz
MBS_ROOT=$MBS_HOME/musicbrainz-server

cd "$MBS_ROOT"

sudo -E -H -u musicbrainz \
    carton exec -- ./script/compile_resources.sh server

exec sudo -E -H -u musicbrainz node root/server.js
