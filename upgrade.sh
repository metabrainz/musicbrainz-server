#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Removing and preventing invalid attributes on links
./admin/psql READWRITE < ./admin/sql/updates/20110726-invalid-attributes.sql

echo `date` : Done

# eof
