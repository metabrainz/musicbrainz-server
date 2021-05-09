#!/usr/bin/env bash
set -o errexit
cd /home/musicbrainz/musicbrainz-server

DATABASE=READWRITE
DIRECTORY=/home/musicbrainz/dumps

if ! script/database_exists $DATABASE; then
    if ! compgen -G "$DIRECTORY/mbdump*.tar.bz2" > /dev/null; then
        RM_DUMPS=true
        curl -o $DIRECTORY/LATEST http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/LATEST
        LATEST="$(cat $DIRECTORY/LATEST)"
        echo "Downloading dump: mbdump-derived.tar.bz2"
        curl -o $DIRECTORY/mbdump-derived.tar.bz2 --retry 15 -C - http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/$LATEST/mbdump-derived.tar.bz2
        echo "Downloading dump: mbdump.tar.bz2"
        curl -o $DIRECTORY/mbdump.tar.bz2 --retry 15 -C - http://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/$LATEST/mbdump.tar.bz2
    fi
    ./admin/InitDb.pl --createdb --database $DATABASE --import $DIRECTORY/mbdump*.tar.bz2 --echo
    if $RM_DUMPS; then
        rm $DIRECTORY/*
    fi
    echo "Completed populating the database."
fi
