#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`
. "$MB_SERVER_ROOT"/admin/config.sh
cd "$MB_SERVER_ROOT"

. ./admin/functions.sh

OUTPUT=`
	./admin/CheckVotes.pl --verbose --summary 2>&1
` || ( echo "$OUTPUT" | mail -s "ModBot output" $ADMIN_EMAILS )

./admin/RemoveOldSessions > /dev/null

OUTPUT=`
	./admin/ResetSigserverCount --threshold=3 2>&1
` || echo "$OUTPUT"

OUTPUT=`
	./admin/RunExport
` || echo "$OUTPUT"

# eof
