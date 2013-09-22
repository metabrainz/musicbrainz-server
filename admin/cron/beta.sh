#!/bin/bash -u

mb_server=`dirname $0`/../..
cd $mb_server

eval `./admin/ShowDBDefs`
source ./admin/config.sh

# Only run one "daily.sh" at a time
if [ "${1:-}" != "gotlock" ]
then
    true ${LOCKFILE:=/tmp/beta.sh.lock}
    $MB_SERVER_ROOT/bin/runexclusive -f "$LOCKFILE" --no-wait \
        $MB_SERVER_ROOT/admin/cron/beta.sh gotlock
    if [ $? = 100 ]
    then
        echo "Aborted - there is already another beta.sh running"
    fi
    exit
fi
# We have the lock - on with the show.

. ./admin/functions.sh
make_temp_dir

# eof
