#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

if [ $REPLICATION_TYPE == 1 ]
then
    echo `date` : Dumping now-replicated tables
    ./admin/ExportAllTables --table=url_gid_redirect --table=work_alias
    mv mbdump.tar.bz2 /var/ftp/pub/musicbrainz/data/20110711-update.tar.bz2
    rm mbdump*.tar.bz2
elif [ $REPLICATION_TYPE == 2 ]
then
    echo `date` : Importing new non-replicated data
    curl -o new_data.tar.bz2 "ftp://data.musicbrainz.org/pub/musicbrainz/data/20110711-update.tar.bz2"
    ./admin/MBImport.pl 20110711-update.tar.bz2
    rm new_data.tar.bz2
fi

echo `date` : Done

# eof
