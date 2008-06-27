#!/bin/sh

set -o errexit

# Abstract: Create PUID tables, loading the initial data set

mb_server=`dirname $0`/../../..
eval `$mb_server/admin/ShowDBDefs`
. "$MB_SERVER_ROOT"/admin/config.sh
cd "$MB_SERVER_ROOT"

function checkfile()
{
	if [ ! -f "$1" ]
	then
		echo "File $1 missing"
		exit 1
	fi
}

# TODO: download from FTP site?
checkfile /tmp/puid.dat
checkfile /tmp/puidjoin.dat

# Create the tables and adjust the albummeta columns
./admin/psql READWRITE < admin/sql/updates/20060310-1.sql

# Drop and recreate functions and triggers
./admin/psql READWRITE < admin/sql/DropTriggers.sql
./admin/psql READWRITE < admin/sql/DropFunctions.sql
./admin/psql READWRITE < admin/sql/CreateFunctions.sql
./admin/psql READWRITE < admin/sql/CreateTriggers.sql

# Turn off replication triggers
if [ $REPLICATION_TYPE = $RT_MASTER ]
then
	./admin/psql READWRITE < admin/sql/DropReplicationTriggers.sql
fi

# Repopulate the album metadata (outside of replication)
./admin/psql READWRITE < admin/sql/PopulateAlbumMeta.sql

# I'm paranoid about albummeta / triggers, so recreating them again can't hurt
./admin/psql READWRITE < admin/sql/DropTriggers.sql
./admin/psql READWRITE < admin/sql/DropFunctions.sql
./admin/psql READWRITE < admin/sql/CreateFunctions.sql
./admin/psql READWRITE < admin/sql/CreateTriggers.sql

# Re-enable replication triggers
if [ $REPLICATION_TYPE = $RT_MASTER ]
then
	./admin/psql READWRITE < admin/sql/CreateReplicationTriggers.sql
elif [ $REPLICATION_TYPE = $RT_SLAVE ]
then
	./admin/psql READWRITE < admin/sql/DropTriggers.sql
fi

./admin/SetSequences.pl

# eof
