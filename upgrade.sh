#!/bin/bash

set -o errexit
cd `dirname $0`
eval `./admin/ShowDBDefs`

if [ "$DB_SCHEMA_SEQUENCE" != "14" ]
then
    echo `date` : Error: Schema sequence must be 14 when you run this script
    exit -1
fi

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : Export pending db changes
    ./admin/RunExport

    echo `date` : Drop replication triggers
    ./admin/psql READWRITE < ./admin/sql/DropReplicationTriggers.sql
fi

echo `date` : Applying 20120420-editor-improvements.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120420-editor-improvements.sql` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Appyling 20120417-improved-aliases.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120417-improved-aliases.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying 20120423-release-group-types.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120423-release-group-types.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying 20120320-remove-url-refcount.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120320-remove-url-refcount.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 20120410-multiple-iswcs-per-work.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120410-multiple-iswcs-per-work.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 20120430-timeline-events.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120430-timeline-events.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : 20120501-timeline-events.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120501-timeline-events.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying 20120405-rename-language-columns.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120405-rename-language-columns.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Running 20120406-update-language-codes.pl
OUTPUT=`./admin/sql/updates/20120406-update-language-codes.pl 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying 20120411-add-work-language.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120411-add-work-language.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying 20120314-add-tracknumber.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120314-add-tracknumber.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying 20120412-add-ipi-tables.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120412-add-ipi-tables.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

echo `date` : Applying 20120508-unknown-end-dates.sql
OUTPUT=`./admin/psql < admin/sql/updates/20120508-unknown-end-dates.sql 2>&1` || ( echo "$OUTPUT" ; exit 1 )

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : Create replication triggers
    ./admin/psql READWRITE < ./admin/sql/CreateReplicationTriggers.sql
fi

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Applying 20120508-unknown-end-dates-constraints.sql
    ./admin/psql < admin/sql/updates/20120508-unknown-end-dates-constraints.sql

    echo `date` : Applying 20120411-add-work-language-constraints.sql
    ./admin/psql < admin/sql/updates/20120411-add-work-language-constraints.sql

    echo `date` : Applying 20120412-add-ipi-tables-constraints.sql
    ./admin/psql < admin/sql/updates/20120412-add-ipi-tables-constraints.sql

    echo `date` : 20120410-multiple-iswcs-per-work.sql
    ./admin/psql < admin/sql/updates/20120410-multiple-iswcs-per-work-constraints.sql

    echo `date` : Applying 20120423-release-group-types-constraints.sql
    ./admin/psql < admin/sql/updates/20120423-release-group-types-constraints.sql

    echo `date` : Appyling 20120417-improved-aliases-constraints.sql
    ./admin/psql < admin/sql/updates/20120417-improved-aliases-constraints.sql

    echo `date` : Applying 20120420-editor-improvements-constraints.sql
    ./admin/psql < admin/sql/updates/20120420-editor-improvements-constraints.sql

    echo `date` : Applying 20120314-add-tracknumber-constraints.sql
    ./admin/psql < admin/sql/updates/20120314-add-tracknumber-constraints.sql
fi

DB_SCHEMA_SEQUENCE=15
echo `date` : Going to schema sequence $DB_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $DB_SCHEMA_SEQUENCE;" | ./admin/psql READWRITE

echo `date` : Done
echo `date` : UPDATE THE DB_SCHEMA_SEQUENCE IN DBDefs.pm TO $DB_SCHEMA_SEQUENCE !

# eof
