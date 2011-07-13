#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Replace special purpose triggers
./admin/psql READWRITE < ./admin/sql/updates/20110713-special-purpose-triggers.sql

echo `date` : Done

# eof
