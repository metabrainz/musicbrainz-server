#!/bin/bash

MD5=`md5sum cpanfile.snapshot | awk '{ print $1 }'`

FTP_DIR='ftp://ftp.musicbrainz.org/pub/musicbrainz/docker/musicbrainz-server'

BUNDLE_NAME=carton-bundle-$MD5.tar.xz

curl -O $FTP_DIR/$BUNDLE_NAME

if [ $? -eq 0 ]; then
    tar xf $BUNDLE_NAME
    rm $BUNDLE_NAME
fi
