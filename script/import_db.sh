#!/bin/bash

set -o errexit
cd `dirname $0`/..

DATABASE=READWRITE
DIRECTORY=./dumps

source ./admin/functions.sh

if ! script/database_exists $DATABASE; then
    count=`ls -l $DIRECTORY/mbdump*.tar.bz2 2>/dev/null | wc -l`
    if [ $count -ne 0 ]; then
        echo "Creating Database and Importing Dump"
        ./admin/InitDb.pl --createdb --database $DATABASE --import $DIRECTORY/mbdump*.tar.bz2 --echo
    else
        echo "Downloading latest MusicBrainz dump"
        wget -nd -nH -P $DIRECTORY http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/LATEST
        LATEST="$(cat $DIRECTORY/LATEST)"
        wget -nd -nH -P $DIRECTORY http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/$LATEST/mbdump-derived.tar.bz2
        wget -nd -nH -P $DIRECTORY http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/$LATEST/mbdump.tar.bz2

        echo "Creating Database and Importing Dump"
        ./admin/InitDb.pl --createdb --database $DATABASE --import $DIRECTORY/mbdump*.tar.bz2 --echo
        echo "Removing downloaded dumps"
        rm $DIRECTORY/*
    fi
fi
