#!/bin/bash

set -o errexit
cd `dirname $0`/..

script/create_test_db.sh

./admin/psql --profile=test READWRITE < ./t/sql/webservice.sql
./admin/psql --profile=test READWRITE < ./t/sql/editor.sql

# eof
