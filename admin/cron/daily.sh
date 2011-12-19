#!/bin/sh

mb_server=`dirname $0`/../..
eval `$mb_server/admin/ShowDBDefs`
. "$MB_SERVER_ROOT"/admin/config.sh
cd "$MB_SERVER_ROOT"

# Only run one "daily.sh" at a time
if [ "$1" != "gotlock" ]
then
    true ${LOCKFILE:=/tmp/daily.sh.lock}
    $MB_SERVER_ROOT/bin/runexclusive -f "$LOCKFILE" --no-wait \
        $MB_SERVER_ROOT/admin/cron/daily.sh gotlock
    if [ $? = 100 ]
    then
        echo "Aborted - there is already another daily.sh running"
    fi
    exit
fi
# We have the lock - on with the show.

. ./admin/functions.sh
make_temp_dir

# Collect stats
echo `date`" : Collecting statistics"
./admin/CollectStats.pl

DATETIME=`date +'%Y%m%d-%H%M%S'`

# Identify and remove unused artists
echo `date`" : Removing unused artists"
./admin/cleanup/EmptyArtists.pl --remove --summary --noverbose

echo `date`" : Removing unused works"
./admin/cleanup/EmptyWorks.pl --remove --summary --noverbose

# Dump all the data
# Only do this on the nominated days (0=Sun 6=Sat)
if date +%w | grep -q [36]
then
    FULL=1
fi
./admin/RunExport $FULL

# Create the reports
echo `date`" : Running reports"
OUTPUT=`
    nice ./admin/RunReports.pl 2>&1
` || echo "$OUTPUT"

# Add missing track lengths
./admin/cleanup/FixTrackLength.pl

# Process subscriptions
echo `date`" : Processing subscriptions"
if date +%w | grep -q [6]
then
    WEEKLY="--weekly"
fi
./admin/ProcessSubscriptions $WEEKLY

# `date`" : Updating language frequencies"
./admin/SetLanguageFrequencies

# Recalculate related tags
./admin/CalculateRelatedTags.sh

echo `date`": Updating cover art links"
./admin/RebuildCoverArtUrls.pl

echo `date`" : Nightly jobs complete!"

# eof
