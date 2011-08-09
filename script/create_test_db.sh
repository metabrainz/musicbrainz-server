#!/bin/bash

set -o errexit
cd `dirname $0`/..

source ./admin/functions.sh

echo 'DROP SCHEMA musicbrainz_test CASCADE;' | ./admin/psql READWRITE
echo 'CREATE SCHEMA musicbrainz_test;' | ./admin/psql READWRITE

if [ `compare_postgres_version 9.1` == "older" ]; then
    echo `date` : Installing extensions
    ./admin/InitDb.pl --install-extension=cube.sql --extension-schema=musicbrainz_test
    ./admin/InitDb.pl --install-extension=musicbrainz_collate.sql  --extension-schema=musicbrainz_test
fi

./admin/psql --profile=test READWRITE <./admin/sql/CreateTables.sql
./admin/psql --profile=test READWRITE <./admin/sql/CreateFunctions.sql
./admin/psql --profile=test --system READWRITE <./admin/sql/CreateSearchConfiguration.sql
./admin/psql --profile=test --system READWRITE <./admin/sql/CreateSystemFunctions.sql

./admin/psql --profile=test READWRITE <./admin/sql/CreatePrimaryKeys.sql
./admin/psql --profile=test READWRITE <./admin/sql/CreateFKConstraints.sql
./admin/psql --profile=test READWRITE <./admin/sql/CreateTriggers.sql

./admin/psql --profile=test READWRITE <./admin/sql/CreateIndexes.sql
./admin/psql --profile=test READWRITE <./admin/sql/CreateSearchIndexes.sql

./admin/psql --profile=test READWRITE < ./t/sql/initial.sql

# eof
