#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`
. $mb_server/admin/config.sh
cd $mb_server

. ./admin/functions.sh
make_temp_dir

OUTPUT=`
	./admin/CheckVotes.pl --verbose --summary 2>&1
` || ( echo "$OUTPUT" | mail -s "ModBot output" $ADMIN_EMAILS )

./admin/RemoveOldSessions > /dev/null

./admin/RunExport

# eof
