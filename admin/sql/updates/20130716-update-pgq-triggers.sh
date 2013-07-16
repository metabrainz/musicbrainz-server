#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Run this as
#
#    carton exec -Ilib -- admin/sql/updates/20130716-update-pgq-triggers.sh
#

echo `date` : Update PGQ triggers

cd "$DIR/../../../"

./admin/psql READWRITE < ./admin/sql/caa/DropPGQ.sql
./admin/psql READWRITE < ./admin/sql/caa/CreatePGQ.sql

echo `date` : Done.
