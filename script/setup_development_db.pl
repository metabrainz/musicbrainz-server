#!/bin/bash

set -o errexit
cd `dirname $0`/..

if [ -z "$1" ]; then
    echo "=========================================================================="
    echo " "
    echo "  WARNING: running this script will overwrite the production database."
    echo "  If you are sure you want to do this, run this:"
    echo " "
    echo "  carton exec -Ilib -- script/setup_development_db.pl --destroy-all-the-things"
    echo " "
    echo "=========================================================================="
elif [ "$1" = "--destroy-all-the-things" ]; then

    # FIXME: initialize the production database, not "create_test_db".
    script/create_test_db.sh
    ./admin/psql READWRITE < ./t/sql/webservice.sql
    ./admin/psql READWRITE < ./t/sql/editor.sql
    ./admin/psql READWRITE < ./admin/sql/SetSequences.sql

else
    echo Unrecognized option "$1"
fi
