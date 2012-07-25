#!/bin/sh

export PATH=/usr/local/bin:$PATH

mb_server=`dirname $0`/../..
cd $mb_server

eval `carton exec -- ./admin/ShowDBDefs`
carton exec -- ./admin/config.sh

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
    carton exec -- ./admin/CheckVotes.pl --verbose --summary 2>&1
` || ( echo "$OUTPUT" | mail -s "ModBot output" $ADMIN_EMAILS )

OUTPUT=`
    carton exec -- ./admin/CheckElectionVotes.pl 2>&1
` || echo "$OUTPUT"

OUTPUT=`
    carton exec -- ./admin/RunExport 2>&1
` || echo "$OUTPUT"

# eof
