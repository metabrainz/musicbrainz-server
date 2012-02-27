#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : MBS-2836: Trim annotations
./admin/psql READWRITE < ./admin/sql/updates/20120213-trim-annotations.sql

echo `date` : Done

# eof
