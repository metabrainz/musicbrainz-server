#!/bin/bash

set -o errexit
cd `dirname $0`/..

source ./admin/functions.sh

echo "
  DROP SCHEMA musicbrainz CASCADE;
  DROP SCHEMA cover_art_archive CASCADE;

  CREATE SCHEMA musicbrainz;
  CREATE SCHEMA cover_art_archive;" | ./admin/psql TEST

if [ `compare_postgres_version 9.1` == "older" ]; then
    echo `date` : Installing extensions
    ./admin/InitDb.pl --install-extension=cube.sql --extension-schema=musicbrainz
    ./admin/InitDb.pl --install-extension=musicbrainz_collate.sql  --extension-schema=musicbrainz
fi

./admin/psql TEST <./admin/sql/CreateTables.sql
./admin/psql TEST <./admin/sql/CreateFunctions.sql
./admin/psql --system TEST <./admin/sql/CreateSearchConfiguration.sql
./admin/psql --system TEST <./admin/sql/CreatePLPerl.sql
./admin/psql TEST <./admin/sql/CreatePrimaryKeys.sql
./admin/psql TEST <./admin/sql/CreateFKConstraints.sql
./admin/psql TEST <./admin/sql/CreateTriggers.sql
./admin/psql TEST <./admin/sql/CreateIndexes.sql
./admin/psql TEST <./admin/sql/CreateSearchIndexes.sql

./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateTables.sql
./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateFunctions.sql
./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreatePrimaryKeys.sql
./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateFKConstraints.sql
./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateTriggers.sql
./admin/psql --schema='cover_art_archive' TEST <./admin/sql/caa/CreateIndexes.sql

./admin/psql TEST < ./t/sql/initial.sql

# eof
