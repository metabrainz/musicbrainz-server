#!/bin/bash

set -o errexit
cd `dirname $0`/..

script/create_test_db.sh

./admin/psql --profile=test READWRITE < ./t/sql/webservice.sql
./admin/psql --profile=test READWRITE < ./t/sql/editor.sql
./admin/psql --profile=test READWRITE < ./admin/sql/SetSequences.sql

echo "===================================================================="
echo " "
echo "  To develop and debug selenium tests using Selenium IDE, run:      "
echo " "
echo "  MUSICBRAINZ_USE_TEST_DATABASE=1 carton exec -Ilib -- plackup -r   "
echo " "
echo "===================================================================="


# eof
