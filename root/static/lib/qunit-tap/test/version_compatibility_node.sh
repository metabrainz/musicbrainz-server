#!/bin/sh

DIR=`dirname $0`

for i in $(ls $DIR/compatibility)
do
    $DIR/node/test_compat.js --version=$i
done
echo ''
