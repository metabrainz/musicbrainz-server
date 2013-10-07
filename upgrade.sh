#!/bin/bash -u

set -o errexit
cd `dirname $0`
eval `./admin/ShowDBDefs`
source ./admin/config.sh

NEW_SCHEMA_SEQUENCE=19
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
echo `date` : 'DROP TABLE puid;'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130807-drop-table-puid.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Remove _name tables and regenerate name columns'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130819-name-tables.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Creating the Place entity'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130618-places.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Updating musicbrainz schema sequence values
OUTPUT=`./admin/psql READWRITE < ./admin/sql/SetSequences.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Mark deleted editors more accurately'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130903-editor-deletion.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Adding ended columns for alias'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130704-ended.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Adding link_type.is_deprecated'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130905-deprecated-link-types.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Creating views'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/CreateViews.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

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
    echo `date` : Applying 20130618-places-fks.sql
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130618-places-fks.sql 2>&1` || ( echo "$OUTPUT"; exit 1 )

    echo `date` : Enabling last_updated triggers
    ./admin/sql/EnableLastUpdatedTriggers.pl

    echo `date` : Recreating constraints/triggers for regenerated tables with name columns
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130830-name-table-fks.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'Adding link_type.is_deprecated triggers'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130910-deprecated-link-types-triggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
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
