#!/usr/bin/env bash

set -e

MBS_HOME=/home/musicbrainz
MBS_ROOT=$MBS_HOME/musicbrainz-server

cd "$MBS_ROOT"

if [ ! -f root/static/build/server.js ]
then
    sudo -E -H -u musicbrainz carton exec -- ./script/compile_resources.sh server
fi

exec sudo -E -H -u musicbrainz carton exec -- ./script/start_renderer.pl
