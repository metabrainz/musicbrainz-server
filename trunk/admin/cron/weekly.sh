#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`
. "$MB_SERVER_ROOT"/admin/config.sh
cd "$MB_SERVER_ROOT"

# Update the search engine statistics
./admin/UpdateWordCounts

# Fix any incorrect "page" values.  There should be none!
./admin/cleanup/FixPageIndexValues --verbose

# eof
