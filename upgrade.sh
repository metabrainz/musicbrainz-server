#!/usr/bin/env bash

set -u
set -o errexit

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$MB_SERVER_ROOT"

source admin/config.sh

: ${DB_SCHEMA_SEQUENCE:=$(perl -Ilib -e 'use DBDefs; print DBDefs->DB_SCHEMA_SEQUENCE;')}
: ${REPLICATION_TYPE:=$(perl -Ilib -e 'use DBDefs; print DBDefs->REPLICATION_TYPE;')}
: ${DATABASE:=MAINTENANCE}
: ${SKIP_EXPORT:=0}

NEW_SCHEMA_SEQUENCE=28
OLD_SCHEMA_SEQUENCE=$((NEW_SCHEMA_SEQUENCE - 1))

RT_MASTER=1
RT_MIRROR=2
RT_STANDALONE=3

SQL_DIR='./admin/sql/updates/schema-change'
EXTENSIONS_SQL="$SQL_DIR/$NEW_SCHEMA_SEQUENCE.all_extensions.sql"
MASTER_ONLY_SQL="$SQL_DIR/$NEW_SCHEMA_SEQUENCE.master_only.sql"
MIRROR_ONLY_SQL="$SQL_DIR/$NEW_SCHEMA_SEQUENCE.mirror_only.sql"

################################################################################
# Assert pre-conditions

if [ "$DB_SCHEMA_SEQUENCE" != "$OLD_SCHEMA_SEQUENCE" ]
then
    echo `date` : Error: Schema sequence must be $OLD_SCHEMA_SEQUENCE when you run this script
    exit -1
fi

################################################################################
# Backup and disable replication triggers

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    if [[ "$SKIP_EXPORT" == "0" ]]
    then
        echo `date` : Export pending db changes
        ./admin/RunExport
    fi

    echo `date` : 'Drop replication triggers (musicbrainz)'
    ./admin/psql "$DATABASE" < ./admin/sql/DropReplicationTriggers.sql
    ./admin/psql "$DATABASE" < ./admin/sql/DropReplicationTriggers2.sql

    for schema in caa documentation eaa statistics wikidocs
    do
        echo `date` : "Drop replication triggers ($schema)"
        ./admin/psql "$DATABASE" < ./admin/sql/$schema/DropReplicationTriggers.sql
        ./admin/psql "$DATABASE" < ./admin/sql/$schema/DropReplicationTriggers2.sql
    done

fi

if [ "$REPLICATION_TYPE" != "$RT_MIRROR" ]
then
    echo `date` : Disabling last_updated triggers
    OUTPUT=`./admin/psql --system "$DATABASE" < ./admin/sql/DisableLastUpdatedTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
fi

################################################################################
# Scripts that should run on *all* nodes (master/mirror/standalone)

echo `date` : 'Running upgrade scripts for all nodes'
if [ -e "$EXTENSIONS_SQL" ]
then
    ./admin/psql --system "$DATABASE" < "$EXTENSIONS_SQL" || exit 1
fi
./admin/psql "$DATABASE" < $SQL_DIR/${NEW_SCHEMA_SEQUENCE}.all.sql || exit 1

################################################################################
# Migrations that apply for only masters
if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    if [ -e "$MASTER_ONLY_SQL" ]
    then
        echo `date` : 'Running upgrade scripts for master nodes'
        ./admin/psql "$DATABASE" < "$MASTER_ONLY_SQL" || exit 1
    fi
fi

################################################################################
# Migrations that apply for only mirrors
if [ "$REPLICATION_TYPE" = "$RT_MIRROR" ]
then
    if [ -e "$MIRROR_ONLY_SQL" ]
    then
        echo `date` : 'Running upgrade scripts for mirror nodes'
        ./admin/psql "$DATABASE" < "$MIRROR_ONLY_SQL" || exit 1
    fi
fi

################################################################################
# Add constraints that apply only to master/standalone (FKS)

if [ "$REPLICATION_TYPE" != "$RT_MIRROR" ]
then
    echo `date` : 'Running upgrade scripts for master/standalone nodes'
    ./admin/psql "$DATABASE" < $SQL_DIR/${NEW_SCHEMA_SEQUENCE}.master_and_standalone.sql || exit 1

    echo `date` : Enabling last_updated triggers
    OUTPUT=`./admin/psql --system "$DATABASE" < ./admin/sql/EnableLastUpdatedTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
fi

################################################################################
# Re-enable replication

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : 'Refreshing dbmirror2.column_info'
    OUTPUT=`./admin/psql --system "$DATABASE" < ./admin/sql/dbmirror2/RefreshColumnInfo.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'Create replication triggers (musicbrainz)'
    OUTPUT=`./admin/psql "$DATABASE" < ./admin/sql/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
    OUTPUT=`./admin/psql "$DATABASE" < ./admin/sql/CreateReplicationTriggers2.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    for schema in caa documentation eaa statistics wikidocs
    do
        echo `date` : "Create replication triggers ($schema)"
        OUTPUT=`./admin/psql "$DATABASE" < ./admin/sql/$schema/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
        OUTPUT=`./admin/psql "$DATABASE" < ./admin/sql/$schema/CreateReplicationTriggers2.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
    done
fi

################################################################################
# Bump schema sequence

echo `date` : Going to schema sequence $NEW_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $NEW_SCHEMA_SEQUENCE;" | ./admin/psql "$DATABASE"

# ignore superuser-only vacuum tables
echo `date` : Vacuuming DB.
echo "SET statement_timeout = 0; VACUUM ANALYZE;" | ./admin/psql MAINTENANCE 2>&1 | grep -v 'only superuser can vacuum it'

################################################################################
# Prompt for final manual intervention

echo `date` : Done
echo `date` : UPDATE THE DB_SCHEMA_SEQUENCE IN DBDefs.pm TO $NEW_SCHEMA_SEQUENCE !

# eof
