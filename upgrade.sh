#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Backing up data
./admin/psql RAWDATA < admin/sql/updates/RAWDATA-backup.sql

echo `date` : Merging duplicate tracklists
./admin/psql READWRITE < ./admin/sql/updates/20110602-merge-duplicate-tracklists.sql

echo `date` : Rewriting empty_artists()
./admin/psql READWRITE < admin/sql/updates/20110607-empty-artists.sql

echo `date` : Fixing old edit label edits
./admin/sql/updates/20110606-fix-historic-edit-label.pl

echo `date` : Fix add release label edits
./admin/sql/updates/20110607-add-release-label.pl

echo `date` : Done

# eof
