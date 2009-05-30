#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Upgrading to N.G.S.!!1!

# echo 'DROP SCHEMA musicbrainz CASCADE;' | ./admin/psql READWRITE
echo 'CREATE SCHEMA musicbrainz;' | ./admin/psql READWRITE

echo `date` : Creating schema
./admin/psql READWRITE <./admin/sql/CreateTables.sql
./admin/psql READWRITE <./admin/sql/CreateFunctions.sql
./admin/psql --system READWRITE <./admin/sql/CreateSearchConfiguration.sql

echo `date` : Migrating data
./admin/psql READWRITE <./admin/sql/updates/ngs.sql
./admin/sql/updates/ngs-ars.pl

echo `date` : Creating primary keys
./admin/psql READWRITE <./admin/sql/CreatePrimaryKeys.sql

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Creating foreign key constraints
    ./admin/psql READWRITE <./admin/sql/CreateFKConstraints.sql
    echo `date` : Creating triggers
    ./admin/psql READWRITE <./admin/sql/CreateTriggers.sql
fi

echo `date` : Creating indexes
./admin/psql READWRITE <./admin/sql/CreateIndexes.sql

echo `date` : Creating search indexes
./admin/psql READWRITE <./admin/sql/CreateSearchIndexes.sql

echo `date` : Done

# eof
