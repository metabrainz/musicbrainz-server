#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Disambiguating Discogs release URLs
./admin/psql READWRITE < admin/sql/updates/20110608-READWRITE-backup-before.sql
./admin/sql/updates/20110608-disambiguate-discogs-relationships.pl
./admin/psql READWRITE < admin/sql/updates/20110608-READWRITE-backup-after.sql

echo `date` : Done

# eof
