#!/bin/bash

set -o errexit
cd `dirname $0`/..

source ./admin/functions.sh

if ! script/database_exists TEST; then
    ./admin/InitDb.pl --createdb --database TEST --clean
fi

echo `date` : Clearing old test database
OUTPUT=`
echo "
  DROP SCHEMA IF EXISTS musicbrainz CASCADE;
  DROP SCHEMA IF EXISTS cover_art_archive CASCADE;

  CREATE SCHEMA musicbrainz;
  CREATE SCHEMA cover_art_archive;" | ./admin/psql --schema=public TEST 2>&1
` || ( echo "$OUTPUT" && exit 1 )

if [ `compare_postgres_version 9.1` == "older" ]; then
    echo `date` : Installing extensions
    ./admin/InitDb.pl --install-extension=cube.sql --extension-schema=musicbrainz
    ./admin/InitDb.pl --install-extension=musicbrainz_collate.sql  --extension-schema=musicbrainz
fi

echo `date` : Creating MusicBrainz Schema
OUTPUT=`./admin/psql TEST <./admin/sql/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql TEST <./admin/sql/CreateFunctions.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --system TEST <./admin/sql/CreateSearchConfiguration.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --system TEST <./admin/sql/CreatePLPerl.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql TEST <./admin/sql/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql TEST <./admin/sql/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql TEST <./admin/sql/CreateTriggers.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql TEST <./admin/sql/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql TEST <./admin/sql/CreateSearchIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql TEST < ./t/sql/initial.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating Cover Art Archive Schema
OUTPUT=`./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateViews.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateFunctions.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateTriggers.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Complete with no errors

# eof
