#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Fixing broken time zones
./admin/psql READWRITE < ./admin/sql/updates/20110525-invalid-timezones.sql

echo `date` : Relinking relationship edits against artists
./admin/sql/updates/20110524-relink-relationships.pl

echo `date` : Fixing edit relationship edits
./admin/sql/updates/20110524-fix-broken-relationship-edits.pl

echo `date` : Done

# eof
