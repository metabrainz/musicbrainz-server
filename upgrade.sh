#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

echo `date` : Renaming RAWDATA musicbrainz schema
echo 'ALTER SCHEMA musicbrainz RENAME TO musicbrainz_raw' | ./admin/psql RAWDATA
echo 'CREATE SCHEMA musicbrainz_raw' | ./admin/psql READWRITE

echo `date` : Dumping RAWDATA
eval $(perl -Ilib -MString::ShellQuote -MDBDefs -MMusicBrainz::Server::DatabaseConnectionFactory -e '
    my $db = MusicBrainz::Server::DatabaseConnectionFactory->get("RAWDATA");
    my $rw = MusicBrainz::Server::DatabaseConnectionFactory->get("READWRITE");
    printf "export MB_RAWDATA_%s=%s\n", uc($_), shell_quote($db->$_),
        for qw( username password schema port database host );
    printf "export MB_READWRITE_%s=%s\n", uc($_), shell_quote($rw->$_),
        for qw( username password schema port database host );
')
pg_dump --format=c --schema=musicbrainz_raw --host=$MB_RAWDATA_HOST --username=$MB_RAWDATA_USERNAME -v \
    $MB_RAWDATA_DATABASE > rawdata.dump

echo `date` : Loading RAWDATA into READWRITE
pg_restore --format=c --schema=musicbrainz_raw --host=$MB_READWRITE_HOST --username=$MB_READWRITE_USERNAME -v \
    -d $MB_READWRITE_DATABASE rawdata.dump

echo `date` : RAWDATA is now part of the READWRITE database.
echo `date` : Please update your DBDefs and feel free to drop the RAWDATA database

echo `date` : Done

# eof
