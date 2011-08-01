#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Adding label code constraints
./admin/psql READWRITE < admin/sql/updates/20110801-label-code-validation.sql

echo `date` : Done

# eof
