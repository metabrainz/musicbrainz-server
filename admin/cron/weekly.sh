#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`
. $mb_server/admin/config.sh
cd $mb_server

# Update the search engine statistics
./admin/UpdateWordCounts

# eof
