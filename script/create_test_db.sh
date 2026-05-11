#!/usr/bin/env bash

set -o errexit
cd `dirname $0`/..

if [ -z "$1" ]; then
    DATABASE=TEST
else
    DATABASE="$1"
fi

source ./admin/functions.sh

INITDB_ARGS=(
    '--database' "$DATABASE"
    '--clean'
    '--initial-sql' 't/sql/initial.sql'
)
if [[ "$REPLICATION_TYPE" == '1' ]]; then
    PG_LIBDIR="$(pg_config --pkglibdir)"
    PENDING_SO="$PG_LIBDIR/pending.so"
    if [[ -f "$PENDING_SO" ]]; then
        INITDB_ARGS+=('--with-pending' "$PENDING_SO")
    fi
fi

if ! script/database_exists $DATABASE; then
    INITDB_ARGS+=('--createdb')
    ./admin/InitDb.pl "${INITDB_ARGS[@]}"
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
    ./admin/InitDb.pl "${INITDB_ARGS[@]}"
fi

echo `date` : Set up pgtap extension
OUTPUT=`echo '\set ON_ERROR_STOP 1' $'\n' \
             'CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA public;' | \
        ./admin/psql --system $DATABASE 2>&1` || \
    ( echo "$OUTPUT" && exit 1 )

echo `date` : Complete with no errors

# eof
