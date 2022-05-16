#!/usr/bin/env bash

# t/script/CheckSchemaMigration.sh tests whether schema change upgrade
# scripts are correct.
#
# This is done by creating two test databases: one from the current
# (schema change) branch, and one from the production branch.
# We then run upgrade.sh on the latter database and dump the schemas
# for both. If they differ, this script will fail and output the
# differences.
#
# Two additional databases must be configured in DBDefs.pm for this
# to work: MIGRATION_TEST1 and MIGRATION_TEST2. Use the names
# musicbrainz_test_migration_1 and musicbrainz_test_migration_2 for
# these respectively.

set -e

MBS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd -P)"
cd "$MBS_ROOT"

if ! (git diff --quiet -- admin/sql && git diff --cached --quiet -- admin/sql)
then
  echo >&2 "$SCRIPT_NAME: admin/sql has local changes; aborting"
  exit 70
fi

: ${SUPERUSER:=postgres}
: ${REPLICATION_TYPE:=2}
# Any custom port specified via the PGPORT environment variable must also be
# used in DBDefs.pm for MIGRATION_TEST1, MIGRATION_TEST2, and SYSTEM.
: ${PGPORT:=5432}
: ${KEEP_TEST_DBS:=0}
: ${PENDING_SO:='/usr/lib/postgresql/12/lib/pending.so'}

function drop_test_dbs() {
    if [[ "$KEEP_TEST_DBS" == "0" ]]; then
        dropdb --host localhost --port "$PGPORT" --user "$SUPERUSER" musicbrainz_test_migration_1
        dropdb --host localhost --port "$PGPORT" --user "$SUPERUSER" musicbrainz_test_migration_2
    fi
}

function cleanup() {
    git restore admin/sql
    drop_test_dbs
}
trap cleanup EXIT

DB1='MIGRATION_TEST1'
DB2='MIGRATION_TEST2'

WITH_PENDING_ARGS=()
if [[ "$REPLICATION_TYPE" == "1" ]]; then
    WITH_PENDING_ARGS+=('--with-pending' "$PENDING_SO")
fi

# DB1 is our baseline schema, created from the current branch.
./admin/InitDb.pl --database $DB1 --createdb --clean --reptype $REPLICATION_TYPE "${WITH_PENDING_ARGS[@]}"

# DB2 is the schema we want to upgrade from. Here we source it
# from the production branch.
git restore --source=production -- admin/sql
git restore --source=production -- admin/InitDb.pl
./admin/InitDb.pl --database $DB2 --createdb --clean --reptype $REPLICATION_TYPE "${WITH_PENDING_ARGS[@]}"
./admin/psql $DB2 < t/sql/initial.sql
./admin/psql $DB2 < admin/sql/SetSequences.sql
git restore admin/sql
git clean --force -- admin/sql
git restore admin/InitDb.pl

export REPLICATION_TYPE
DB_SCHEMA_SEQUENCE=26 DATABASE=$DB2 SKIP_EXPORT=1 ./upgrade.sh

DB1SCHEMA="$DB1.schema.sql"
DB2SCHEMA="$DB2.schema.sql"

pg_dump \
    --host localhost \
    --port "$PGPORT" \
    --schema-only \
    --superuser "$SUPERUSER" \
    --dbname musicbrainz_test_migration_1 \
    --username musicbrainz > "$DB1SCHEMA"

pg_dump \
    --host localhost \
    --port "$PGPORT" \
    --schema-only \
    --superuser "$SUPERUSER" \
    --dbname musicbrainz_test_migration_2 \
    --username musicbrainz > "$DB2SCHEMA"

drop_test_dbs

exec diff "$DB1SCHEMA" "$DB2SCHEMA"
