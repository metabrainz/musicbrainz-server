#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Backing up data
./admin/psql READWRITE < ./admin/sql/updates/20110525-READWRITE-backup.sql

echo `date` : Making medium-cdtoc pairs unique
./admin/psql READWRITE < ./admin/sql/updates/20110530-duplicate-cdtocs.sql

echo `date` : Done

# eof
