#!/usr/bin/env bash -u

set -o errexit

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$MB_SERVER_ROOT"

source admin/config.sh

DB_SCHEMA_SEQUENCE=$(perl -Ilib -e 'use DBDefs; print DBDefs->DB_SCHEMA_SEQUENCE;')
REPLICATION_TYPE=$(perl -Ilib -e 'use DBDefs; print DBDefs->REPLICATION_TYPE;')

NEW_SCHEMA_SEQUENCE=26
OLD_SCHEMA_SEQUENCE=$((NEW_SCHEMA_SEQUENCE - 1))

RT_MASTER=1
RT_SLAVE=2
RT_STANDALONE=3

SQL_DIR='./admin/sql/updates/schema-change'
EXTENSIONS_SQL="$SQL_DIR/$NEW_SCHEMA_SEQUENCE.extensions.sql"
SLAVE_ONLY_SQL="$SQL_DIR/$NEW_SCHEMA_SEQUENCE.slave_only.sql"

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
    echo `date` : Export pending db changes
    ./admin/RunExport

    echo `date` : 'Drop replication triggers (musicbrainz)'
    ./admin/psql MAINTENANCE < ./admin/sql/DropReplicationTriggers.sql

    for schema in caa documentation statistics wikidocs
    do
        echo `date` : "Drop replication triggers ($schema)"
        ./admin/psql MAINTENANCE < ./admin/sql/$schema/DropReplicationTriggers.sql
    done

fi

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Disabling last_updated triggers
    ./admin/sql/DisableLastUpdatedTriggers.pl
fi

################################################################################
# Migrations that apply for only slaves
if [ "$REPLICATION_TYPE" = "$RT_SLAVE" ]
then
    if [ -e "$SLAVE_ONLY_SQL" ]
    then
        echo `date` : 'Running upgrade scripts for slave nodes'
        ./admin/psql MAINTENANCE < "$SLAVE_ONLY_SQL" || exit 1
    fi
fi

################################################################################
# Scripts that should run on *all* nodes (master/slave/standalone)

echo `date` : 'Running upgrade scripts for all nodes'
if [ -e "$EXTENSIONS_SQL" ]
then
    ./admin/psql --system MAINTENANCE < "$EXTENSIONS_SQL" || exit 1
fi
./admin/psql MAINTENANCE < $SQL_DIR/${NEW_SCHEMA_SEQUENCE}.slave.sql || exit 1

################################################################################
# Re-enable replication

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : 'Create replication triggers (musicbrainz)'
    OUTPUT=`./admin/psql MAINTENANCE < ./admin/sql/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    for schema in caa documentation statistics wikidocs
    do
        echo `date` : "Create replication triggers ($schema)"
        OUTPUT=`./admin/psql MAINTENANCE < ./admin/sql/$schema/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
    done
fi

################################################################################
# Add constraints that apply only to master/standalone (FKS)

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : 'Running upgrade scripts for master/standalone nodes'
    ./admin/psql MAINTENANCE < $SQL_DIR/${NEW_SCHEMA_SEQUENCE}.standalone.sql || exit 1

    echo `date` : Enabling last_updated triggers
    ./admin/sql/EnableLastUpdatedTriggers.pl
fi

################################################################################
# Bump schema sequence

echo `date` : Going to schema sequence $NEW_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $NEW_SCHEMA_SEQUENCE;" | ./admin/psql MAINTENANCE

# ignore superuser-only vacuum tables
echo `date` : Vacuuming DB.
echo "SET statement_timeout = 0; VACUUM ANALYZE;" | ./admin/psql MAINTENANCE 2>&1 | grep -v 'only superuser can vacuum it'

################################################################################
# Prompt for final manual intervention

echo `date` : Done
echo `date` : UPDATE THE DB_SCHEMA_SEQUENCE IN DBDefs.pm TO $NEW_SCHEMA_SEQUENCE !

# eof
