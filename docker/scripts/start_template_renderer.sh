#!/bin/bash

set -e

MBS_HOME=/home/musicbrainz
MBS_ROOT=$MBS_HOME/musicbrainz-server

cd "$MBS_ROOT"

exec sudo -E -H -u musicbrainz node root/server.js
