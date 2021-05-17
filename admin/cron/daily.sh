#!/usr/bin/env bash

set -u

export PATH=/usr/local/bin:$PATH

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

source admin/config.sh

# Only run one "daily.sh" at a time
if [ "${1:-}" != "gotlock" ]
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

echo `date`" : Removing unused artists"
./admin/cleanup/RemoveEmpty artist

echo `date`" : Removing unused events"
./admin/cleanup/RemoveEmpty event

echo `date`" : Removing unused labels"
./admin/cleanup/RemoveEmpty label

echo `date`" : Removing unused places"
./admin/cleanup/RemoveEmpty place

echo `date`" : Removing unused release groups"
./admin/cleanup/RemoveEmpty release_group

echo `date`" : Removing unused series"
./admin/cleanup/RemoveEmpty series

echo `date`" : Removing unused works"
./admin/cleanup/RemoveEmpty work

# Dump all the data
# Only do this on the nominated days 3=Wed and 6=Sat (for reference 0=Sun)
if date +%w | grep -qw '[36]'
then
    FULL=1
fi
./admin/RunExport ${FULL:-}

# Do any necessary packet bundling
echo `date`" : Bundling replication packets, daily"
./admin/replication/BundleReplicationPackets $FTP_DATA_DIR/replication --period daily --require-previous
if date +%w | grep -qw '[6]'
then
    echo `date`" : + weekly"
    ./admin/replication/BundleReplicationPackets $FTP_DATA_DIR/replication --period weekly --require-previous
fi

# Create the reports
echo `date`" : Running reports"
nice ./admin/RunReports.pl

# Add missing track lengths
./admin/cleanup/FixTrackLength.pl

# Process subscriptions
echo `date`" : Processing subscriptions"
if date +%w | grep -qw '[6]'
then
    WEEKLY="--weekly"
fi
./admin/ProcessSubscriptions ${WEEKLY:-}

# `date`" : Updating language frequencies"
./admin/SetLanguageFrequencies

echo `date`" : Updating cover art links"
./admin/RebuildCoverArtUrls.pl

echo `date`" : Nightly jobs complete!"
