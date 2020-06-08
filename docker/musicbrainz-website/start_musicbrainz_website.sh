#!/bin/bash

set -e

MBS_HOME=/home/musicbrainz
MBS_ROOT=$MBS_HOME/musicbrainz-server

source "$MBS_ROOT/script/functions.sh"

cd $MBS_ROOT

deploy_static_resources.sh &
trap_jobs

export NODE_ENV=production

sudo -E -H -u musicbrainz \
    carton exec -- ./script/compile_resources.sh server &
trap_jobs

sv start template-renderer

exec start_musicbrainz_server.sh
