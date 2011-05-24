#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Fixing edit relationship edits
./admin/sql/updates/20110524-fix-broken-relationship-edits.pl

echo `date` : Done

# eof
