#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Backing up data
./admin/psql RAWDATA < admin/sql/updates/RAWDATA-backup.sql

echo `date` : Adding special purpose row constraints
./admin/psql READWRITE < admin/sql/updates/20110808-special-purpose-triggers.sql

echo `date` : Rewriting empty_artists()
./admin/psql READWRITE < admin/sql/updates/20110607-empty-artists.sql

echo `date` : Fixing old edit label edits
./admin/sql/updates/20110606-fix-historic-edit-label.pl

echo `date` : "Creating additional artist and label name indexes (MBS-2347)."
./admin/psql READWRITE < admin/sql/updates/20110613-unaccent-lower-index.sql

echo `date` : Fix add release label edits
./admin/sql/updates/20110607-add-release-label.pl

echo `date` : Disambiguating Discogs release URLs
./admin/psql READWRITE < admin/sql/updates/20110608-READWRITE-backup-before.sql
./admin/sql/updates/20110608-disambiguate-discogs-relationships.pl
./admin/psql READWRITE < admin/sql/updates/20110608-READWRITE-backup-after.sql

echo `date` : Making medium-cdtoc pairs unique
./admin/psql READWRITE < ./admin/sql/updates/20110530-duplicate-cdtocs.sql

echo `date` : Done

# eof
