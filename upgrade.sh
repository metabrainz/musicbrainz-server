#!/bin/bash -u

set -o errexit
cd `dirname $0`
eval `./admin/ShowDBDefs`

NEW_SCHEMA_SEQUENCE=18
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
    carton exec -- ./admin/replication/BundleReplicationPackets $FTP_DATA_DIR/replication --period daily --require-previous
    echo `date`" : + weekly"
    carton exec -- ./admin/replication/BundleReplicationPackets $FTP_DATA_DIR/replication --period weekly --require-previous

    # We are only updating tables in the main namespace for this change.
    echo `date` : 'Drop replication triggers (musicbrainz)'
    ./admin/psql READWRITE < ./admin/sql/DropReplicationTriggers.sql
fi

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Disabling last_updated triggers
    ./admin/sql/DisableLastUpdatedTriggers.pl
fi

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    # export
    echo `date` : Exporting just the track tables for slaves to use
    mkdir -p catchup
    ./admin/ExportAllTables --table='track' -d catchup
fi

if [ "$REPLICATION_TYPE" = "$RT_SLAVE" ]
then
    # import
    echo `date` : Downloading correct track table
    mkdir -p catchup
    OUTPUT=`wget -q "ftp://ftp.musicbrainz.org/pub/musicbrainz/data/schema-change-2013-05-15/mbdump.tar.bz2" -O catchup/mbdump.tar.bz2` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Fixing the track table

    echo `date` : Dropping indexes on the track table
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130520-drop-track-indexes.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Emptying the track table
    OUTPUT=`echo 'DELETE FROM track' | ./admin/psql 2>&1` || ( echo "$OUTPUT" ; exit 1)

    echo `date` : Importing the version of the track table from master
    ./admin/MBImport.pl --tmp-dir=/mnt/music/tmp --skip-editor catchup/mbdump.tar.bz2

    echo `date` : Recreating indexes on the track table
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130520-create-track-indexes.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
fi

################################################################################
# Scripts that should run on *all* nodes (master/slave/standalone)
echo `date` : Updating musicbrainz schema sequence values
OUTPUT=`./admin/psql READWRITE < ./admin/sql/SetSequences.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Fix the artist_credit.ref_count column
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130520-update-artist-credit-refcount-faster.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Creating an index on medium.release
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130520-medium-release-index.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Renaming track2013_ and medium2013_ indexes and constraints
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130520-rename-indexes-constraints.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

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
    echo `date` : Enabling last_updated triggers
    ./admin/sql/EnableLastUpdatedTriggers.pl

    echo `date` : Adding track constraints
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130520-readd-track-constraints.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Re-add artist_credit FKs
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130520-update-artist-credit-refcount-faster-fks.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

fi

################################################################################
# Bump schema sequence

echo `date` : Going to schema sequence $NEW_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $NEW_SCHEMA_SEQUENCE;" | ./admin/psql READWRITE

################################################################################
# Prompt for final manual intervention

echo `date` : Done
echo `date` : UPDATE THE DB_SCHEMA_SEQUENCE IN DBDefs.pm TO $NEW_SCHEMA_SEQUENCE !

# eof
