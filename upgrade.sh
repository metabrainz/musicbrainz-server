#!/bin/bash -u

set -o errexit
cd `dirname $0`
eval `./admin/ShowDBDefs`

################################################################################
# Assert pre-conditions

if [ "$DB_SCHEMA_SEQUENCE" != "15" ]
then
    echo `date` : Error: Schema sequence must be 15 when you run this script
    exit -1
fi

# Slaves need to 'catch up' on the CAA tables. They cannot run the migration
# unless this dump is present.
if [ "$REPLICATION_TYPE" = "$RT_SLAVE" ]
then
    echo `date` : Downloading cover art archive metadata
    mkdir -p catchup
    OUTPUT=`wget -q "ftp://ftp.musicbrainz.org/pub/musicbrainz/data/schema-change-2012-10-15/mbdump-cover-art-archive.tar.bz2" -O catchup/mbdump-cover-art-archive.tar.bz2` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Catching up with cover_art_archive schema
    OUTPUT=`echo 'DROP SCHEMA IF EXISTS cover_art_archive CASCADE' | ./admin/psql 2>&1` || ( echo "$OUTPUT" ; exit 1)
    OUTPUT=`echo 'CREATE SCHEMA cover_art_archive' | ./admin/psql 2>&1` || ( echo "$OUTPUT" ; exit 1)
    OUTPUT=`./admin/psql < admin/sql/updates/20121015-caa-as-of-schema-15.sql 2>&1` || ( echo "$OUTPUT" ; exit 1)
    OUTPUT=`./admin/psql < admin/sql/caa/CreateFunctions.sql 2>&1` || ( echo "$OUTPUT" ; exit 1)
    OUTPUT=`./admin/psql < admin/sql/caa/CreateViews.sql 2>&1` || ( echo "$OUTPUT" ; exit 1)
    OUTPUT=`./admin/MBImport.pl --skip-editor catchup/mbdump-cover-art-archive.tar.bz2 2>&1` || ( echo "$OUTPUT" ; exit 1 )
fi

################################################################################
# Backup and disable replication triggers

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : Export pending db changes
    ./admin/RunExport

    echo `date` : Drop replication triggers
    ./admin/psql READWRITE < ./admin/sql/DropReplicationTriggers.sql

    echo `date` : 'Drop replication triggers (statistics)'
    echo 'DROP TRIGGER "reptg_statistic" ON "statistic";
          DROP TRIGGER "reptg_statistic_event" ON "statistic_event";' | ./admin/psql READWRITE

    echo `date` : Exporting just CAA tables for slaves to catchup
    mkdir -p catchup
    ./admin/ExportAllTables --table='cover_art_archive.art_type' \
        --table='cover_art_archive.cover_art' \
        --table='cover_art_archive.cover_art_type' \
        -d catchup
fi

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Disabling last_updated triggers
    ./admin/sql/DisableLastUpdatedTriggers.pl
fi

################################################################################
# Scripts that should run on *all* nodes (master/slave/standalone)

echo `date` : Updating sequence values
OUTPUT=`./admin/psql READWRITE < ./admin/sql/SetSequences.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying admin/sql/updates/20121017-whitespace-functions.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20121017-whitespace-functions.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Dropping broken indexes
OUTPUT=`echo 'DROP INDEX IF EXISTS artist_idx_uniq_name_comment' | ./admin/psql 2>&1` || ( echo "$OUTPUT" ; exit 1)
OUTPUT=`echo 'DROP INDEX IF EXISTS label_idx_uniq_name_comment' | ./admin/psql 2>&1` || ( echo "$OUTPUT" ; exit 1)

echo `date` : Applying admin/sql/updates/20120220-merge-duplicate-credits.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120220-merge-duplicate-credits.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying admin/sql/updates/20120822-more-text-constraints.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120822-more-text-constraints.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying admin/sql/updates/20120917-rg-st-created.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120917-rg-st-created.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying admin/sql/updates/20120921-drop-url-descriptions.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120921-drop-url-descriptions.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying admin/sql/updates/20120922-move-statistics-tables.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120922-move-statistics-tables.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying admin/sql/updates/20120927-add-log-statistics.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120927-add-log-statistics.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

if [ "$REPLICATION_TYPE" = "$RT_SLAVE" ]
then
    echo `date` : Applying admin/sql/updates/20120911-not-null-comments.sql
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120911-not-null-comments.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
fi

echo `date` : Applying admin/sql/updates/20120919-caa-edits-pending.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120919-caa-edits-pending.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying admin/sql/updates/20120921-release-group-cover-art.sql
OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120921-release-group-cover-art.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

if [ "$REPLICATION_TYPE" = "$RT_SLAVE" ]
then
    echo `date` : Indexing new cover_art_archive data
    OUTPUT=`./admin/psql < admin/sql/caa/CreatePrimaryKeys.sql 2>&1` || ( echo "$OUTPUT" ; exit 1)
    OUTPUT=`./admin/psql < admin/sql/caa/CreateIndexes.sql 2>&1` || ( echo "$OUTPUT" ; exit 1)
fi

################################################################################
# Re-enable replication

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : 'Create replication triggers (musicbrainz)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'Create replication triggers (cover_art_archive)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/caa/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : 'Create replication triggers (statistics)'
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/statistics/CreateReplicationTriggers.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )
fi

################################################################################
# Add constraints that apply only to master/standalone (FKS)

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Adding master constraints

    echo `date` : Enabling last_updated triggers
    ./admin/sql/EnableLastUpdatedTriggers.pl

    echo `date` : Applying admin/sql/updates/20120822-more-text-constraints-master.sql
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120822-more-text-constraints-master.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

    echo `date` : Applying admin/sql/updates/20120911-not-null-comments-master.sql
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120911-not-null-comments-master.sql 2>&1` || ( echo "$OUTPUT" ; echo "This has *not* stopped migration, but will need to be re-ran later!" )

    echo `date` : Applying admin/sql/updates/20120921-release-group-cover-art-master.sql
    OUTPUT=`./admin/psql READWRITE < ./admin/sql/updates/20120921-release-group-cover-art-master.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

fi

################################################################################
# Bump schema sequence

DB_SCHEMA_SEQUENCE=16
echo `date` : Going to schema sequence $DB_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $DB_SCHEMA_SEQUENCE;" | ./admin/psql READWRITE

################################################################################
# Prompt for final manual intervention

echo `date` : Done
echo `date` : UPDATE THE DB_SCHEMA_SEQUENCE IN DBDefs.pm TO $DB_SCHEMA_SEQUENCE !

# eof
