#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Removing entirely orphaned recordings
./admin/psql READWRITE < admin/sql/updates/20110721-orphaned-recordings.sql

echo `date` : Done

# eof
