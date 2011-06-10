#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Adding special purpose row constraints
./admin/psql READWRITE < admin/sql/updates/20110808-special-purpose-triggers.sql

echo `date` : "Creating additional artist and label name indexes (MBS-2347)."
./admin/psql READWRITE < admin/sql/updates/20110613-unaccent-lower-index.sql

echo `date` : Done

# eof
