#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Adding support for finding edits by relationship type
./admin/psql --system READWRITE < admin/sql/updates/20110804-json-extract.sql

echo `date` : Adding new edit indexes
./admin/psql READWRITE < admin/sql/updates/20110804-relationship-edit-indexes.sql

echo `date` : Done

# eof
