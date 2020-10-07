#!/bin/bash

set -e

MBS_HOME=/home/musicbrainz
MBS_ROOT=$MBS_HOME/musicbrainz-server

cd "$MBS_ROOT"

exec sudo -E -H -u musicbrainz node --icu-data-dir=node_modules/full-icu root/server.js
