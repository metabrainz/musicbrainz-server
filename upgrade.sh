#!/bin/bash

set -o errexit
cd `dirname $0`

eval `./admin/ShowDBDefs`

if [ $REPLICATION_TYPE == $RT_MASTER ]
then
    echo `date` : Recreating tracklist_index
    ./admin/psql READWRITE < admin/sql/updates/20110710-tracklist-index.sql

    echo `date` : Dumping now-replicated tables
    ./admin/ExportAllTables --table=url_gid_redirect --table=work_alias --table=tracklist_index
    mv mbdump.tar.bz2 /var/ftp/pub/musicbrainz/data/20110711-update.tar.bz2
    rm mbdump*.tar.bz2

    echo `date` : Registering new triggers
    ./admin/psql READWRITE < admin/sql/updates/201107011-triggers.sql

    echo `date` : Please remember to *sync* the new data!
elif [ $REPLICATION_TYPE == $RT_SLAVE ]
then
    echo `date` : Importing new non-replicated data
    ./admin/psql READWRITE < admin/sql/updates/20110710-tracklist-index-slave-before.sql
    echo 'TRUNCATE tracklist_index' | ./admin/psql READWRITE
    curl -o new_data.tar.bz2 "ftp://data.musicbrainz.org/pub/musicbrainz/data/20110711-update.tar.bz2"
    ./admin/MBImport.pl 20110711-update.tar.bz2
    ./admin/psql READWRITE < admin/sql/updates/20110710-tracklist-index-slave-after.sql
    rm 20110711-update.tar.bz
fi

echo `date` : Done

# eof
