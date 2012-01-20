#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

if [ "$DB_SCHEMA_SEQUENCE" != "13" ]
then
    echo `date` : Error: Schema sequence must be 13 when you run this script!
    exit -1
fi

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : Export pending db changes
    ./admin/RunExport

    echo `date` : Drop replication triggers
    ./admin/psql READWRITE < ./admin/sql/DropReplicationTriggers.sql
fi

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
     echo `date` : Adding support for finding edits by relationship type
    ./admin/psql --system READWRITE < admin/sql/updates/20110804-json-extract.sql

    echo `date` : Adding new edit indexes
    ./admin/psql READWRITE < admin/sql/updates/20110804-relationship-edit-indexes.sql
fi

echo `date` : Adding CAA flag to release_meta
./admin/psql READWRITE < ./admin/sql/updates/20120105-caa-flag.sql

DB_SCHEMA_SEQUENCE=14
echo `date` : Going to schema sequence $DB_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $DB_SCHEMA_SEQUENCE;" | ./admin/psql READWRITE

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
    echo `date` : Create replication triggers
    ./admin/psql READWRITE < ./admin/sql/CreateReplicationTriggers.sql
fi

echo `date` : UPDATE THE DB_SCHEMA_SEQUENCE IN DBDefs.pm TO $DB_SCHEMA_SEQUENCE !

echo `date` : Done

# eof
