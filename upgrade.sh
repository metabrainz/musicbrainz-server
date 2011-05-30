#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : "Rewrite empty_artists()"
./admin/psql READWRITE < ./admin/sql/updates/20110530-empty-artists.sql

echo `date` : Done

# eof
