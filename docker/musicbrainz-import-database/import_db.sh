#!/bin/bash

cd /home/musicbrainz/musicbrainz-server
carton exec -- ./script/import_db.sh
