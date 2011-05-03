#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`
. "$MB_SERVER_ROOT"/admin/config.sh
cd "$MB_SERVER_ROOT"

# Only run one "hourly.sh" at a time
if [ "$1" != "gotlock" ]
then
    true ${LOCKFILE:=/tmp/hourly.sh.lock}
    $MB_SERVER_ROOT/bin/runexclusive -f "$LOCKFILE" --no-wait \
        $MB_SERVER_ROOT/admin/cron/hourly.sh gotlock
    if [ $? = 100 ]
    then
        echo "Aborted - there is already another hourly.sh running"
    fi
    exit
fi
# We have the lock - on with the show.

. ./admin/functions.sh

OUTPUT=`
    ./admin/CheckVotes.pl --verbose --summary 2>&1
` || ( echo "$OUTPUT" | mail -s "ModBot output" $ADMIN_EMAILS )

OUTPUT=`
    ./admin/RunExport 2>&1
` || echo "$OUTPUT"

# eof
