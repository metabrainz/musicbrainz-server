#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Backing up data
./admin/psql READWRITE < ./admin/sql/updates/20110525-READWRITE-backup.sql
./admin/psql RAWDATA < ./admin/sql/updates/20110525-RAWDATA-backup.sql

echo `date` : Fixing broken time zones
./admin/psql READWRITE < ./admin/sql/updates/20110525-invalid-timezones.sql

echo `date` : Rewriting short link phrases for relationships
./admin/psql READWRITE < ./admin/sql/updates/20110524-short-link-phrases.sql

echo `date` : Upgrading relationship edit types to include short link phrases
./admin/sql/updates/20110524-short-link-phrase-edits.pl

echo `date` : Relinking relationship edits against artists
./admin/sql/updates/20110524-relink-relationships.pl

echo `date` : Fixing edit relationship edits
./admin/sql/updates/20110524-fix-broken-relationship-edits.pl

echo `date` : Done

# eof
