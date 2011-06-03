#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Backing up data
./admin/psql RAWDATA < ./admin/sql/updates/20110527-RAWDATA-backup.sql

echo `date` : "Rewrite empty_artists()"
./admin/psql READWRITE < ./admin/sql/updates/20110530-empty-artists.sql

echo `date` : Upgrade historic artist credits
./admin/sql/updates/20110527-historic-artist-credits.pl

echo `date` : Done

# eof
