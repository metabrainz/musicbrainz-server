#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Upgrading to N.G.S.!!1!

#echo 'DROP SCHEMA musicbrainz CASCADE;' | ./admin/psql READWRITE
#echo 'DROP SCHEMA musicbrainz CASCADE;' | ./admin/psql RAWDATA
echo 'CREATE SCHEMA musicbrainz;' | ./admin/psql READWRITE
echo 'CREATE SCHEMA musicbrainz;' | ./admin/psql RAWDATA

echo `date` : Installing cube extension
./admin/InitDb.pl --install-extension=cube.sql --extension-schema=musicbrainz

echo `date` : Installing musicbrainz-collate extension
./admin/InitDb.pl --install-extension=musicbrainz_collate.sql --extension-schema=musicbrainz

echo `date` : Creating schema
./admin/psql READWRITE <./admin/sql/CreateTables.sql
./admin/psql READWRITE <./admin/sql/CreateFunctions.sql
./admin/psql --system READWRITE <./admin/sql/CreateSearchConfiguration.sql
./admin/psql RAWDATA <./admin/sql/vertical/rawdata/CreateTables.sql
./admin/psql RAWDATA <./admin/sql/vertical/rawdata/CreateFunctions.sql

echo `date` : Migrating data
./admin/psql READWRITE <./admin/sql/updates/ngs-artist.sql
./admin/sql/updates/ngs-artistcredit.pl
./admin/psql READWRITE <./admin/sql/updates/ngs.sql
./admin/sql/updates/ngs-ars.pl
./admin/sql/updates/ngs-rawdata.pl
./admin/sql/updates/ngs-artistcredit-2.pl
./admin/psql READWRITE <./admin/sql/updates/ngs-link-phrases.sql

echo `date` : Merging releases
./admin/sql/updates/ngs-merge-releases.pl
echo `date` : Merging recordings
./admin/sql/updates/ngs-merge-recordings.pl
echo `date` : Merging works
./admin/sql/updates/ngs-merge-works.pl
echo `date` : Create tracklist index
./admin/psql READWRITE < ./admin/sql/updates/ngs-cdlookup.sql
echo `date`: Merging urls
./admin/sql/updates/ngs-merge-urls.pl

echo `date` : Fixing refcounts
./admin/psql READWRITE <./admin/sql/updates/ngs-refcount.sql

echo `date` : Migrating edits
echo This step currently disabled
 ./admin/sql/updates/ngs-migrate-edits.pl

echo `date` : Creating primary keys
./admin/psql READWRITE <./admin/sql/CreatePrimaryKeys.sql
./admin/psql RAWDATA <./admin/sql/vertical/rawdata/CreatePrimaryKeys.sql

#echo `date` : Collecting cover art URLs
./admin/psql READWRITE < ./admin/sql/updates/ngs-fast-rebuild-coverart.sql
./admin/RebuildCoverArtUrls.pl

if [ "$REPLICATION_TYPE" != "$RT_SLAVE" ]
then
    echo `date` : Creating foreign key constraints
    ./admin/psql READWRITE <./admin/sql/CreateFKConstraints.sql
    ./admin/psql RAWDATA <./admin/sql/vertical/rawdata/CreateFKConstraints.sql
    echo `date` : Creating triggers
    ./admin/psql READWRITE <./admin/sql/CreateTriggers.sql
    echo `date` : Adding table constraints
    ./admin/psql READWRITE <./admin/sql/CreateConstraints.sql
fi

echo `date` : Creating indexes
./admin/psql READWRITE <./admin/sql/CreateIndexes.sql
./admin/psql RAWDATA <./admin/sql/vertical/rawdata/CreateIndexes.sql

echo `date` : Creating search indexes
./admin/psql READWRITE <./admin/sql/CreateSearchIndexes.sql

echo `date` : Fixing sequences
./admin/psql READWRITE <./admin/sql/SetSequences.sql
./admin/psql RAWDATA <./admin/sql/vertical/rawdata/SetSequences.sql

echo `date` : Going to schema sequence $DB_SCHEMA_SEQUENCE
echo "UPDATE replication_control SET current_schema_sequence = $DB_SCHEMA_SEQUENCE;" | ./admin/psql READWRITE

echo `date`: Cleaning up and vacuuming
# echo 'DROP TABLE tmp_recording_merge' | ./admin/psql READWRITE
# echo 'DROP TABLE tmp_recording_merge' | ./admin/psql RAWDATA
# echo 'DROP TABLE tmp_release_merge'   | ./admin/psql READWRITE
# echo 'DROP TABLE tmp_release_album'   | ./admin/psql READWRITE
echo 'VACUUM ANALYZE;' | ./admin/psql READWRITE
echo 'VACUUM ANALYZE;' | ./admin/psql RAWDATA

echo `date` : Done

# eof
