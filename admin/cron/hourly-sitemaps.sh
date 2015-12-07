#!/bin/bash -u

mb_server=`dirname $0`/../..
cd $mb_server

OUTPUT=`
    ./admin/BuildIncrementalSitemaps.pl --ping 2>&1
` || echo "$OUTPUT"

# eof
