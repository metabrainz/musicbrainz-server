#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Unlinked PUID edits
./admin/sql/updates/20110524-relink-relationships.pl

echo `date` : Done

# eof
