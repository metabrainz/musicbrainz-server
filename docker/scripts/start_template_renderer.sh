#!/bin/bash

set -e

source /etc/mbs_constants.sh

cd "$MBS_ROOT"

sudo -E -H -u musicbrainz \
    carton exec -- ./script/compile_resources.sh server

exec sudo -E -H -u musicbrainz node root/server.js
