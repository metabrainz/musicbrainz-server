#!/bin/sh

DIR=`dirname $0`
$DIR/pack.py $DIR/editsuite.conf
$DIR/pack.py $DIR/musicbrainz.conf
$DIR/pack.py $DIR/entervalidate.conf
