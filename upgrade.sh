#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Upgrading to RELEASE-20070401-BRANCH


# This replication packet will have the old SCHEMA_SEQUENCE number

if [ "$REPLICATION_TYPE" = "$RT_MASTER" ]
then
	# The old / new schema sequence numbers
	OLD_SEQ=$(( $DB_SCHEMA_SEQUENCE - 1 ))
	NEW_SEQ=$DB_SCHEMA_SEQUENCE
	# The final export of the old schema needs to run under the old sequence number
	perl -i -pwe 's/\b\d+\b/'$OLD_SEQ'/ if m/^sub DB_SCHEMA_SEQUENCE /' ./cgi-bin/DBDefs.pm
#TODO:
# This needs to run under the OLD branch!
#	./admin/RunExport
	perl -i -pwe 's/\b\d+\b/'$NEW_SEQ'/ if m/^sub DB_SCHEMA_SEQUENCE /' ./cgi-bin/DBDefs.pm
fi

# Drop the old replication triggers on the master, so that the changes in 20070813-1.sql don't create
# massive replication packets.
[ "$REPLICATION_TYPE" = "$RT_MASTER" ] && echo `date` : Drop replication triggers
[ "$REPLICATION_TYPE" = "$RT_MASTER" ] && ./admin/psql READWRITE < ./admin/sql/updates/20070401-1.sql

echo `date` : Create RAWDATA database
./admin/InitDb.pl --createrawonly --clean

echo `date` : Add tags support to database
./admin/psql READWRITE < ./admin/sql/updates/20070622-1.sql
[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && ./admin/psql READWRITE < ./admin/sql/updates/20070622-2.sql
./admin/psql RAWDATA < ./admin/sql/updates/20070622-3.sql

echo `date` : Add subscribe to editor database tables
./admin/psql READWRITE < ./admin/sql/updates/20070719-1.sql
[ "$REPLICATION_TYPE" != "$RT_SLAVE" ] && ./admin/psql READWRITE < ./admin/sql/updates/20070719-2.sql

echo `date` : Adding AR improvements
./admin/psql READWRITE < ./admin/sql/updates/20070813-1.sql

echo `date` : Fixing PUID counts, changing moderation tables
./admin/psql READWRITE < ./admin/sql/updates/20070921-1.sql

# Drop the functions and triggers in order to fix the one wrong PUID update function
echo `date` : Re loading functions
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
