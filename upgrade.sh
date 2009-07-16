#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Upgrading to N.G.S.!!1!

# echo 'DROP SCHEMA musicbrainz CASCADE;' | ./admin/psql READWRITE
# echo 'DROP SCHEMA musicbrainz CASCADE;' | ./admin/psql RAWDATA
echo 'CREATE SCHEMA musicbrainz;' | ./admin/psql READWRITE
echo 'CREATE SCHEMA musicbrainz;' | ./admin/psql RAWDATA

echo `date` : Creating schema
./admin/psql READWRITE <./admin/sql/CreateTables.sql
./admin/psql READWRITE <./admin/sql/CreateFunctions.sql
./admin/psql --system READWRITE <./admin/sql/CreateSearchConfiguration.sql
./admin/psql RAWDATA <./admin/sql/vertical/rawdata/CreateTables.sql

echo `date` : Migrating data
./admin/psql READWRITE <./admin/sql/updates/ngs.sql
./admin/sql/updates/ngs-ars.pl
./admin/sql/updates/ngs-rawdata.pl

echo `date` : Fixing refcounts
./admin/psql READWRITE <./admin/sql/updates/ngs-refcount.sql

echo `date` : Creating primary keys
./admin/psql READWRITE <./admin/sql/CreatePrimaryKeys.sql
./admin/psql RAWDATA <./admin/sql/vertical/rawdata/CreatePrimaryKeys.sql

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Creating foreign key constraints
    ./admin/psql READWRITE <./admin/sql/CreateFKConstraints.sql
    ./admin/psql RAWDATA <./admin/sql/vertical/rawdata/CreateFKConstraints.sql
    echo `date` : Creating triggers
    ./admin/psql READWRITE <./admin/sql/CreateTriggers.sql
fi

echo `date` : Creating indexes
./admin/psql READWRITE <./admin/sql/CreateIndexes.sql
./admin/psql RAWDATA <./admin/sql/vertical/rawdata/CreateIndexes.sql

echo `date` : Creating search indexes
./admin/psql READWRITE <./admin/sql/CreateSearchIndexes.sql

echo `date` : Fixing sequences
./admin/psql READWRITE <./admin/sql/SetSequences.sql
./admin/psql RAWDATA <./admin/sql/vertical/rawdata/SetSequences.sql

echo `date` : Done

# eof
