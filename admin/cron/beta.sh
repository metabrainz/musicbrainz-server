#!/bin/sh

mb_server=`dirname $0`/../..
cd "$MB_SERVER_ROOT"

eval `carton exec -- ./admin/ShowDBDefs`
. "$MB_SERVER_ROOT"/admin/config.sh


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
    nice carton exec -- ./admin/RunReports.pl 2>&1
` || echo "$OUTPUT"

echo `date`" : Recalculating editor statistics"
carton exec -Ilib -- perl -e '
    use MusicBrainz::Server::Context;
    my $c = MusicBrainz::Server::Context->create_script_context;
    $c->model("Statistics")->top_recently_active_editors;
    $c->model("Statistics")->top_editors;
    $c->model("Statistics")->top_recently_active_voters;
    $c->model("Statistics")->top_voters,
'

echo `date`" : Beta jobs complete!"

# eof
