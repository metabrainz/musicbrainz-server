#!/bin/bash

set -o errexit
cd `dirname $0`/..

echo 'DROP SCHEMA musicbrainz_test CASCADE;' | ./admin/psql READWRITE
echo 'CREATE SCHEMA musicbrainz_test;' | ./admin/psql READWRITE

PG_VERSION=$( echo "SELECT version()" | ./admin/psql READWRITE | egrep 'PostgreSQL 9.[^0].' )

echo `date` : Installing extensions
if [ -n "$PG_VERSION" ]; then
#    ./admin/psql --profile=test READWRITE < ./admin/sql/Extensions.sql
    true
else
    ./admin/InitDb.pl --install-extension=cube.sql --extension-schema=musicbrainz_test
    ./admin/InitDb.pl --install-extension=musicbrainz_collate.sql  --extension-schema=musicbrainz_test
fi

./admin/psql --profile=test READWRITE <./admin/sql/CreateTables.sql
./admin/psql --profile=test READWRITE <./admin/sql/CreateFunctions.sql
./admin/psql --profile=test --system READWRITE <./admin/sql/CreateSearchConfiguration.sql

./admin/psql --profile=test READWRITE <./admin/sql/CreatePrimaryKeys.sql
./admin/psql --profile=test READWRITE <./admin/sql/CreateFKConstraints.sql
./admin/psql --profile=test READWRITE <./admin/sql/CreateTriggers.sql

./admin/psql --profile=test READWRITE <./admin/sql/CreateIndexes.sql
./admin/psql --profile=test READWRITE <./admin/sql/CreateSearchIndexes.sql

./admin/psql --profile=test READWRITE < ./t/sql/initial.sql

# eof
