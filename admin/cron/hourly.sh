#!/usr/bin/env bash

set -u

if [[ -t 1 ]]
then
    exec 2>&1 | ts '%X %Z'
fi

export PATH=/usr/local/bin:$PATH
export PERL_CARTON_PATH=~/carton-local

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

source admin/config.sh

# Only run one "hourly.sh" at a time
if [ "${1:-}" != "gotlock" ]
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

./admin/CheckVotes.pl --verbose --summary

./admin/CheckElectionVotes.pl

# This performs a fairly heavy query and really only needs to run once
# per day or less. Do this outside of peak hours (03:00 UTC).
if date +%H | grep -qFx '03'
then
    ./admin/cleanup/MergeDuplicateArtistCredits --limit 100
fi

./admin/RunExport
