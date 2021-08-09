#!/usr/bin/env bash

# Important for logging stack traces.
exec 2>&1

MBS_HOME=/home/musicbrainz
MBS_ROOT=$MBS_HOME/musicbrainz-server

cd $MBS_ROOT

export HOME=$MBS_HOME
export MUSICBRAINZ_USE_PROXY=1

PID_FILE=/tmp/musicbrainz-server.pid
if [ -s "$PID_FILE" ]; then
    OLD_PID=$(<$PID_FILE)
    if kill -0 $OLD_PID 2> /dev/null; then
        kill -TERM $OLD_PID
        (sleep 30; kill -9 $OLD_PID 2> /dev/null) &
        while kill -0 $OLD_PID 2> /dev/null; do sleep 1; done
    fi
fi

chpst -u musicbrainz:musicbrainz \
    carton exec -- ./script/dbdefs_exists \
    || exit $?

exec chpst -u musicbrainz:musicbrainz \
    carton exec -- \
        start_server --port 5000 --pid-file "$PID_FILE" -- \
            plackup \
                -Ilib \
                --server Starlet \
                --env deployment \
                --max-workers ${STARLET_MAX_WORKERS:-10} \
                --min-reqs-per-child 30 \
                --max-reqs-per-child 90 \
                app.psgi
