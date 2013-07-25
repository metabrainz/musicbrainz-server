#!/bin/bash

set -o errexit
cd `dirname $0`/..

if [ -z "$1" ]; then
    DATABASE=TEST
else
    DATABASE="$1"
fi

source ./admin/functions.sh

if ! script/database_exists $DATABASE; then
    ./admin/InitDb.pl --createdb --database $DATABASE --clean
fi

echo `date` : Clearing old test database
OUTPUT=`
echo "
  DROP SCHEMA IF EXISTS musicbrainz CASCADE;
  DROP SCHEMA IF EXISTS statistics CASCADE;
  DROP SCHEMA IF EXISTS cover_art_archive CASCADE;
  DROP SCHEMA IF EXISTS documentation CASCADE;
  DROP SCHEMA IF EXISTS wikidocs CASCADE;

  CREATE SCHEMA musicbrainz;
  CREATE SCHEMA statistics;
  CREATE SCHEMA cover_art_archive;
  CREATE SCHEMA documentation;
  CREATE SCHEMA wikidocs;" | ./admin/psql --schema=public $DATABASE 2>&1
` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating MusicBrainz Schema
OUTPUT=`./admin/psql --system $DATABASE <./admin/sql/Extensions.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateFunctions.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --system $DATABASE <./admin/sql/CreateSearchConfiguration.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --system $DATABASE <./admin/sql/CreatePLPerl.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateTriggers.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateSearchIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE < ./t/sql/initial.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating Statistics Schema
OUTPUT=`./admin/psql --schema='statistics' $DATABASE <./admin/sql/statistics/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='statistics' $DATABASE <./admin/sql/statistics/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='statistics' $DATABASE <./admin/sql/statistics/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating Cover Art Archive Schema
OUTPUT=`./admin/psql --schema='cover_art_archive' $DATABASE <./admin/sql/caa/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' $DATABASE <./admin/sql/caa/CreateViews.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' $DATABASE <./admin/sql/caa/CreateFunctions.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' $DATABASE <./admin/sql/caa/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' $DATABASE <./admin/sql/caa/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' $DATABASE <./admin/sql/caa/CreateTriggers.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='cover_art_archive' $DATABASE <./admin/sql/caa/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating Wikidocs Schema
OUTPUT=`./admin/psql --schema='wikidocs' $DATABASE <./admin/sql/wikidocs/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='wikidocs' $DATABASE <./admin/sql/wikidocs/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating documentation Schema
OUTPUT=`./admin/psql --schema='documentation' $DATABASE <./admin/sql/documentation/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='documentation' $DATABASE <./admin/sql/documentation/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --schema='documentation' $DATABASE <./admin/sql/documentation/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Set up pgtap extension
OUTPUT=`echo "CREATE EXTENSION pgtap WITH SCHEMA public;" | ./admin/psql $DATABASE 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Complete with no errors

# eof
