#!/usr/bin/env bash

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
  DROP SCHEMA IF EXISTS event_art_archive CASCADE;
  DROP SCHEMA IF EXISTS wikidocs CASCADE;
  DROP SCHEMA IF EXISTS sitemaps CASCADE;
  DROP SCHEMA IF EXISTS json_dump CASCADE;
  DROP SCHEMA IF EXISTS dbmirror2 CASCADE;

  CREATE SCHEMA musicbrainz;
  CREATE SCHEMA statistics;
  CREATE SCHEMA cover_art_archive;
  CREATE SCHEMA documentation;
  CREATE SCHEMA event_art_archive;
  CREATE SCHEMA wikidocs;
  CREATE SCHEMA sitemaps;
  CREATE SCHEMA json_dump;
  CREATE SCHEMA dbmirror2;" | ./admin/psql $DATABASE 2>&1
` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating MusicBrainz Schema
OUTPUT=`./admin/psql --system $DATABASE <./admin/sql/Extensions.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql --system $DATABASE <./admin/sql/CreateSearchConfiguration.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateCollations.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateTypes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateViews.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateFunctions.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateTriggers.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/CreateSearchIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating Statistics Schema
OUTPUT=`./admin/psql $DATABASE <./admin/sql/statistics/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/statistics/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/statistics/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating Cover Art Archive Schema
OUTPUT=`./admin/psql $DATABASE <./admin/sql/caa/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/caa/CreateViews.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/caa/CreateFunctions.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/caa/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/caa/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/caa/CreateTriggers.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/caa/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating Wikidocs Schema
OUTPUT=`./admin/psql $DATABASE <./admin/sql/wikidocs/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/wikidocs/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating documentation Schema
OUTPUT=`./admin/psql $DATABASE <./admin/sql/documentation/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/documentation/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/documentation/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating Event Art Archive Schema
OUTPUT=`./admin/psql $DATABASE <./admin/sql/eaa/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/eaa/CreateViews.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/eaa/CreateFunctions.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/eaa/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/eaa/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/eaa/CreateTriggers.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/eaa/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating sitemaps Schema
OUTPUT=`./admin/psql $DATABASE <./admin/sql/sitemaps/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/sitemaps/CreateFKConstraints.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/sitemaps/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating json_dump Schema
OUTPUT=`./admin/psql $DATABASE <./admin/sql/json_dump/CreateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/json_dump/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/json_dump/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Creating replication setup
OUTPUT=`./admin/psql $DATABASE <./admin/sql/ReplicationSetup.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/dbmirror2/ReplicationSetup.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Set up pgtap extension
OUTPUT=`echo "CREATE EXTENSION pgtap WITH SCHEMA public;" | ./admin/psql $DATABASE 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Inserting initial data
OUTPUT=`./admin/psql $DATABASE < ./t/sql/initial.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql $DATABASE <./admin/sql/SetSequences.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Complete with no errors

# eof
