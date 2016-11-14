#!/bin/bash

set -e

source /etc/mbs_constants.sh

cd $MBS_ROOT

carton exec -- perl -Ilib /usr/local/bin/install_language_packs.pl
deploy_static_resources.sh
start_musicbrainz_server.sh
