#!/bin/sh


export PATH=/usr/local/bin:$PATH

mb_server=`dirname $0`/../..
cd $mb_server

eval `./admin/ShowDBDefs`
source ./admin/config.sh

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
OUTPUT=`./admin/CollectStats.pl` || echo "$OUTPUT"

DATETIME=`date +'%Y%m%d-%H%M%S'`

echo `date`" : Removing unused artists"
OUTPUT=`./admin/cleanup/RemoveEmpty artist` || echo "$OUTPUT"

echo `date`" : Removing unused labels"
OUTPUT=`./admin/cleanup/RemoveEmpty label` || echo "$OUTPUT"

echo `date`" : Removing unused release groups"
OUTPUT=`./admin/cleanup/RemoveEmpty release_group` || echo "$OUTPUT"

echo `date`" : Removing unused works"
OUTPUT=`./admin/cleanup/RemoveEmpty work` || echo "$OUTPUT"
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


# eof
