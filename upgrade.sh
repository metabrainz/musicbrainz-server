#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Backing up data
./admin/psql RAWDATA < ./admin/sql/updates/RAWDATA-backup.sql

echo `date` : Fix add release label edits
./admin/sql/updates/20110607-add-release-label.pl

echo `date` : Done

# eof
