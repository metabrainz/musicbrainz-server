#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`
./admin/psql READWRITE < ./admin/sql/updates/20110624-cdtoc-indexes.sql

echo `date` : Done

# eof
