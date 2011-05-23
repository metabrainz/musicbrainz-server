#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Unlinked PUID edits
./admin/psql RAWDATA < ./admin/sql/updates/20110521.sql

echo `date` : Making sure ISRC recording pairs are unique
./admin/psql READWRITE < ./admin/sql/updates/hotfixes2-20110523-unique-isrcs.sql

echo `date` : Cleaning up edit relationship edits
./admin/sql/updates/hotfix2-20110523-edit-relationship.pl

echo `date` : Done

# eof
