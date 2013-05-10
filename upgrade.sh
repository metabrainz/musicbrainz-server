#!/bin/bash -u

set -o errexit
cd `dirname $0`
eval `./admin/ShowDBDefs`

NEW_SCHEMA_SEQUENCE=17
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

    echo `date` : Initialize bundled replication packets
    ./admin/sql/updates/20130322-init-bundled-replication.pl

    echo `date` : 'Drop replication triggers (musicbrainz)'
    ./admin/psql READWRITE < ./admin/sql/DropReplicationTriggers.sql

    echo `date` : 'Drop replication triggers (cover_art_archive)'
    ./admin/psql READWRITE < ./admin/sql/caa/DropReplicationTriggers.sql

    echo `date` : 'Drop replication triggers (statistics)'
    ./admin/psql READWRITE < ./admin/sql/statistics/DropReplicationTriggers.sql
fi

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Disabling last_updated triggers
    ./admin/sql/DisableLastUpdatedTriggers.pl
fi

################################################################################
# Scripts that should run on *all* nodes (master/slave/standalone)
echo `date` : 'Creating wikidocs transclusion table'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130222-transclusion-table.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'MBS-5861, work attributes'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130414-work-attributes.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'MBS-4115, Add cover art image types'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130117-cover-image-types.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying admin/sql/updates/20130312-collection-descriptions.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130312-collection-descriptions.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Create documentation tables'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130313-relationship-documentation.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Creditable link attributes'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130313-instrument-credits.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Dropping work.artist_credit'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130222-drop-work.artist_credit.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying 20130322-multiple-country-dates.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130322-multiple-country-dates.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 20130225-rename-link_type.short_link_phrase.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130225-rename-link_type.short_link_phrase.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Creating the Area entity'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130301-areas.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130425-edit-area.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'Creating relationship documentation for areas'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130510-relationship-documentation-areas.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Updating musicbrainz schema sequence values
OUTPUT=`./admin/psql READWRITE < ./admin/sql/SetSequences.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 'MBS-1839, Reduplicate tracklists'
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130318-track-mbid-reduplicate-tracklists.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying admin/sql/updates/20120914-isni.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120914-isni.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

################################################################################
# Re-enable replication

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : 'Create replication triggers (musicbrainz)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'Create replication triggers (documentation)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/documentation/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'Create replication triggers (cover_art_archive)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/caa/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'Create replication triggers (statistics)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/statistics/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'Create replication triggers (wikidocs)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/wikidocs/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
fi

################################################################################
# Add constraints that apply only to master/standalone (FKS)

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Adding master constraints
    echo `date` : Applying 20130309-areas-fks.sql
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130309-areas-fks.sql 2>&1` || ( echo "$OUTPUT"; exit 1 )

    echo `date` : Applying 20130425-edit-area-fk.sql
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130425-edit-area-fk.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Applying 20130426-area-edits.sql
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130426-area-edits.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'Creating relationship documentation for areas (fks)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130510-relationship-documentation-areas-fks.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Applying 20130322-multiple-country-dates-constraints.sql
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130322-multiple-country-dates-constraints.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Adding ISNI constraints
    OUTPUT=`./admin/psql READWRITE < admin/sql/updates/20120914-isni-constraints.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'MBS-4115, Add cover art image types (foreign keys)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130117-cover-image-type-foreign-keys.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Enabling last_updated triggers
    ./admin/sql/EnableLastUpdatedTriggers.pl

    echo `date` : 'MBS-5861, work attribute foreign keys'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130414-work-attributes-fks.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'MBS-1839, Add track MBID foreign keys'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130318-track-mbid-foreign-keys.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'MBS-1839, Update track triggers'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20130318-track-mbid-track-triggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
fi

################################################################################
# Migrate the wiki transclusion table (AFTER replication, so it is replicated)

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : 'Migrate wiki transclusion table'
    OUTPUT=`./admin/sql/updates/20130309-migrate-transclusion-table.pl 2>&1` || ( echo "$OUTPUT" ; exit 1 )
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
