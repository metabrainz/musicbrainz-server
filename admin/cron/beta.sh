#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`
. "$MB_SERVER_ROOT"/admin/config.sh
cd "$MB_SERVER_ROOT"

# Only run one "daily.sh" at a time
if [ "$1" != "gotlock" ]
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

# Collect stats
DATETIME=`date +'%Y%m%d-%H%M%S'`

# Create the reports
echo `date`" : Running reports"
OUTPUT=`
    nice ./admin/RunReports.pl 2>&1
` || echo "$OUTPUT"

echo `date`" : Beta jobs complete!"

# eof
