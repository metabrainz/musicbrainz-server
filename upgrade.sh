#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Fixing broken time zones
./admin/psql READWRITE < ./admin/sql/updates/20110525-invalid-timezones.sql

echo `date` : Done

# eof
