#!/bin/bash -u

mb_server=`dirname $0`/../..
cd $mb_server

OUTPUT=`./admin/cron/slave.sh 2>&1` || echo "$OUTPUT"

OUTPUT=`
    ./admin/BuildIncrementalSitemaps.pl --ping --worker-count 7 2>&1
` || echo "$OUTPUT"

# eof
