#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Upgrading to RELEASE-20081123-BRANCH

# Drop the old replication triggers on the master, so that the changes in 20080201-1.sql don't create
# massive replication packets.
[ "$REPLICATION_TYPE" = "$RT_MASTER" ] && echo `date` : Drop replication triggers
[ "$REPLICATION_TYPE" = "$RT_MASTER" ] && ./admin/psql READWRITE < ./admin/sql/updates/20070401-1.sql

echo `date` : Adding RawCD support
./admin/psql READWRITE < ./admin/sql/updates/20071212-1.sql

echo `date` : Adding AR improvements
./admin/psql READWRITE < ./admin/sql/updates/20080201-1.sql

echo `date` : Drop TRMs!
./admin/psql READWRITE < ./admin/sql/updates/20080529.sql

echo `date` : Add meta tables
./admin/psql READWRITE < ./admin/sql/updates/20080610-1.sql
[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && ./admin/psql READWRITE < ./admin/sql/updates/20080610-2.sql

echo `date` : Add ratings support to database
./admin/psql READWRITE < ./admin/sql/updates/20080707-1.sql
./admin/psql RAWDATA < ./admin/sql/updates/20080707-2.sql

echo `date` : Add collection support to database
./admin/psql RAWDATA < ./admin/sql/updates/20080711-1.sql

echo `date` : Add dateadded, fix moderation and track fields type
./admin/psql READWRITE < ./admin/sql/updates/20080729.sql

[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && echo `date` : Populating albummeta.dateadded
[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && ./admin/sql/updates/PopulateAlbumDateAdded.pl

echo `date` : Add tags relation support to database
./admin/psql READWRITE < ./admin/sql/updates/20081017-1.sql
[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && ./admin/psql READWRITE < ./admin/sql/updates/20081017-2.sql

[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && echo `date` : Generate new stats from past moderations and votes
[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && ./admin/psql READWRITE < ./admin/sql/updates/20081027.sql

# Drop the functions and triggers in order to fix the one wrong PUID update function
echo `date` : Re loading functions
# RAUOK: We've got a minor issue here. We're dropping the triggers from the current codebase which attempts
#        to drop triggers and functions that don't exist. This shouldn't be a problem, but it would be good to check
[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && ./admin/psql READWRITE < ./admin/sql/DropTriggers.sql
./admin/psql READWRITE < ./admin/sql/DropFunctions.sql
./admin/psql READWRITE < ./admin/sql/CreateFunctions.sql
[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && ./admin/psql READWRITE < ./admin/sql/CreateTriggers.sql

[ "$REPLICATION_TYPE" = "$RT_MASTER" ] && echo `date` : Create replication triggers
[ "$REPLICATION_TYPE" = "$RT_MASTER" ] && ./admin/psql READWRITE < ./admin/sql/CreateReplicationTriggers.sql

echo `date` : Going to schema sequence $DB_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $DB_SCHEMA_SEQUENCE;" | ./admin/psql READWRITE

# We're now at the new schema, so the next replication packet (if we are
# the master) will have the new SCHEMA_SEQUENCE number; thus, it can only
# be applied to a new schema.

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
	./admin/cleanup/ModPending.pl
	./admin/cleanup/UpdateCoverArt.pl
fi

echo `date` : Done

# eof
