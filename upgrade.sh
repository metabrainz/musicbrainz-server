#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Adding unused_urls function
./admin/psql READWRITE < admin/sql/updates/20110808-unused-url.sql

echo `date` : Done

# eof
