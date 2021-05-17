#!/usr/bin/env bash

exec sudo -E -H -u musicbrainz sh -c 'cd ~/musicbrainz-server && carton exec -- ./script/dbdefs_to_js.pl'
