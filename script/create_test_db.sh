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
    ./admin/InitDb.pl --createdb --database $DATABASE --clean --initial-sql 't/sql/initial.sql'
else
    echo `date` : Clearing old test database
    OUTPUT=`
    echo "
      DROP SCHEMA IF EXISTS musicbrainz CASCADE;
      DROP SCHEMA IF EXISTS statistics CASCADE;
      DROP SCHEMA IF EXISTS cover_art_archive CASCADE;
      DROP SCHEMA IF EXISTS documentation CASCADE;
      DROP SCHEMA IF EXISTS event_art_archive CASCADE;
      DROP SCHEMA IF EXISTS report CASCADE;
      DROP SCHEMA IF EXISTS wikidocs CASCADE;
      DROP SCHEMA IF EXISTS sitemaps CASCADE;
      DROP SCHEMA IF EXISTS json_dump CASCADE;
      DROP SCHEMA IF EXISTS dbmirror2 CASCADE;" | ./admin/psql $DATABASE 2>&1
    ` || ( echo "$OUTPUT" && exit 1 )
    ./admin/InitDb.pl --database $DATABASE --clean --initial-sql 't/sql/initial.sql'
fi

echo `date` : Set up pgtap extension
OUTPUT=`echo "CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA public;" | \
        ./admin/psql --system $DATABASE 2>&1` || \
    ( echo "$OUTPUT" && exit 1 )

echo `date` : Complete with no errors

# eof
