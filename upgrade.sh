#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Upgrading to RELEASE-20081123-BRANCH

# Drop the old replication triggers on the master, so that the changes in 20080201-1.sql don't create
# massive replication packets.
if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
	echo `date` : Drop replication triggers
	./admin/psql READWRITE < ./admin/sql/updates/20070401-1.sql
fi

echo `date` : Update script, language and country tables
./admin/psql READWRITE < ./admin/sql/updates/20081115-1.sql

echo `date` : Adding CD Stub support
./admin/psql RAWDATA < ./admin/sql/updates/20071212-1.sql

echo `date` : Adding AR improvements
./admin/psql READWRITE < ./admin/sql/updates/20080201-1.sql

echo `date` : 'Drop TRMs!'
./admin/psql READWRITE < ./admin/sql/updates/20080529.sql

echo `date` : Add meta tables
./admin/psql READWRITE < ./admin/sql/updates/20080610-1.sql
if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
	# constraints
	./admin/psql READWRITE < ./admin/sql/updates/20080610-2.sql
fi

echo `date` : Add ratings support to database
./admin/psql READWRITE < ./admin/sql/updates/20080707-1.sql
./admin/psql RAWDATA < ./admin/sql/updates/20080707-2.sql

echo `date` : Add collection support to database
./admin/psql RAWDATA < ./admin/sql/updates/20080711-1.sql

echo `date` : Add dateadded, fix moderation and track fields type
./admin/psql READWRITE < ./admin/sql/updates/20080729.sql

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
	echo `date` : Populating albummeta.dateadded
	./admin/sql/updates/PopulateAlbumDateAdded.pl
fi

echo `date` : Add tags relation support to database
./admin/psql READWRITE < ./admin/sql/updates/20081017-1.sql

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
	# constraints
	./admin/psql READWRITE < ./admin/sql/updates/20081017-2.sql
fi

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
	echo `date` : Generate new stats from past moderations and votes
	./admin/psql READWRITE < ./admin/sql/updates/20081027.sql
fi

# Drop the functions and triggers in order to fix the one wrong PUID update function
echo `date` : Re loading functions

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
	./admin/psql READWRITE < ./admin/sql/DropTriggers.sql
fi

./admin/psql READWRITE < ./admin/sql/DropFunctions.sql
./admin/psql READWRITE < ./admin/sql/CreateFunctions.sql

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
	./admin/psql READWRITE < ./admin/sql/CreateTriggers.sql
fi

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
	echo `date` : Create replication triggers
	./admin/psql READWRITE < ./admin/sql/CreateReplicationTriggers.sql
fi

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
