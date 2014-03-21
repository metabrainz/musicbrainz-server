#!/bin/bash -u

set -o errexit
cd `dirname $0`
eval `./admin/ShowDBDefs`
source ./admin/config.sh

NEW_SCHEMA_SEQUENCE=20
OLD_SCHEMA_SEQUENCE=$((NEW_SCHEMA_SEQUENCE - 1))

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

    echo `date`" : Bundling replication packets, daily"
    ./admin/replication/BundleReplicationPackets $FTP_DATA_DIR/replication --period daily --require-previous
    echo `date`" : + weekly"
    ./admin/replication/BundleReplicationPackets $FTP_DATA_DIR/replication --period weekly --require-previous

    # We are only updating tables in the main namespace for this change.
    echo `date` : 'Drop replication triggers (musicbrainz)'
    ./admin/psql READWRITE < ./admin/sql/DropReplicationTriggers.sql
fi

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Disabling last_updated triggers
    ./admin/sql/DisableLastUpdatedTriggers.pl
fi

################################################################################
# Migrations that apply for only slaves
#if [ "$REPLICATION_TYPE" = "$RT_SLAVE" ]
#then
#fi

################################################################################
# Scripts that should run on *all* nodes (master/slave/standalone)

echo `date` : 'Adding ordering columns'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20140212-ordering-columns.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'DROP TABLE script_language;'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20140208-drop-script_language.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

################################################################################
# Re-enable replication

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : 'Create replication triggers (musicbrainz)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
fi

################################################################################
# Add constraints that apply only to master/standalone (FKS)

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : 'Adding foreign keys for ordering columns'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20140308-ordering-columns-fk.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Enabling last_updated triggers
    ./admin/sql/EnableLastUpdatedTriggers.pl
fi

################################################################################
# Bump schema sequence

echo `date` : Going to schema sequence $NEW_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $NEW_SCHEMA_SEQUENCE;" | ./admin/psql READWRITE

# ignore superuser-only vacuum tables
echo `date` : Vacuuming DB.
echo "VACUUM ANALYZE;" | ./admin/psql READWRITE 2>&1 | grep -v 'only superuser can vacuum it'

################################################################################
# Prompt for final manual intervention

echo `date` : Done
echo `date` : UPDATE THE DB_SCHEMA_SEQUENCE IN DBDefs.pm TO $NEW_SCHEMA_SEQUENCE !

# eof
