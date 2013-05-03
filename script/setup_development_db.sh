#!/bin/bash

set -o errexit
cd `dirname $0`/..

if [ -z "$1" ]; then
    echo "=========================================================================="
    echo " "
    echo "  WARNING: running this script will overwrite the production database."
    echo "  If you are sure you want to do this, run this:"
    echo " "
    echo "  carton exec -Ilib -- script/setup_development_db.sh --destroy-all-the-things"
    echo " "
    echo "=========================================================================="
elif [ "$1" = "--destroy-all-the-things" ]; then

    script/create_test_db.sh READWRITE
    ( printf "BEGIN;\n"; cat ./t/sql/webservice.sql; printf "\nCOMMIT;\n"; ) | ./admin/psql READWRITE
    ./admin/psql READWRITE < ./t/sql/editor.sql
    ./admin/psql READWRITE < ./admin/sql/SetSequences.sql

else
    echo Unrecognized option "$1"
fi
