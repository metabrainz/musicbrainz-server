#!/bin/bash

set -e

source /etc/mbs_constants.sh
source "$MBS_ROOT/script/functions.sh"

cd $MBS_ROOT

deploy_static_resources.sh &
trap_jobs

sv start template-renderer

exec start_musicbrainz_server.sh
