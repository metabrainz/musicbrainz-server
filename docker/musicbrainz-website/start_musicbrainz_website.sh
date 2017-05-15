#!/bin/bash

set -e

source /etc/mbs_constants.sh
source "$MBS_ROOT/script/functions.sh"

cd $MBS_ROOT

carton exec -- perl -Ilib /usr/local/bin/install_language_packs.pl &
trap_jobs

deploy_static_resources.sh &
trap_jobs

sv start template-renderer

exec start_musicbrainz_server.sh
