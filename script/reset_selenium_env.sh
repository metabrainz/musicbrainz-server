#!/usr/bin/env bash

set -o errexit

EXTRA_SQL="$1"
MBS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd -P)"
SIR_LOG_FILE="$MBS_ROOT"/t/selenium/.sir-amqp_watch.log
SIR_PID_FILE="$MBS_ROOT"/t/selenium/.sir-amqp_watch.pid
SIR_REINDEX_LOG_FILE="$MBS_ROOT"/t/selenium/.sir-reindex.log

terminate_pg_backends() {
    echo `date` : Terminating all PG backends
    local CANCEL_QUERY=$(cat <<'SQL'
\set ON_ERROR_STOP 1
SELECT pg_terminate_backend(pid)
  FROM pg_stat_activity
 WHERE usename = 'musicbrainz'
   AND pid <> pg_backend_pid();
SQL
    )
    echo "$CANCEL_QUERY" | ./admin/psql SELENIUM -- --single-transaction -v ON_ERROR_STOP=1
}

if [[ $SIR_DIR ]]; then
    # Stop sir to avoid deadlocks below.
    if [[ -f $SIR_PID_FILE ]]; then
        SIR_PID="$(cat "$SIR_PID_FILE")"
    fi

    if [[ $SIR_PID ]] && kill -0 "$SIR_PID" > /dev/null 2>&1; then
        echo `date` : Stopping sir
        kill -TERM "$SIR_PID"
        echo '' > "$SIR_PID_FILE"
    fi

    terminate_pg_backends

    echo `date` : Purging sir queues
    ./script/purge_sir_queues.sh /sir-test

    echo `date` : Purging Solr cores
    ./script/purge_solr_cores.sh
else
    terminate_pg_backends
fi

echo `date` : Creating Selenium test database
OUTPUT=`./script/create_selenium_db.sh "$EXTRA_SQL" 2>&1` || ( echo "$OUTPUT" && exit 1 )

if [[ $SIR_DIR ]]; then
    pushd "$SIR_DIR"
    . venv/bin/activate

    # Unfortunately, we must work around SOLR-109 for the time being by
    # detecting when the reindex command is stuck.
    reindex_attempts=0
    while true; do
        echo `date` : Reindexing search data
        echo '==========' `date` '==========' >> "$SIR_REINDEX_LOG_FILE"
        python -m sir --debug reindex >> "$SIR_REINDEX_LOG_FILE" 2>&1 &
        SIR_PID=$!
        disown
        let 'reindex_attempts = reindex_attempts + 1'

        wait_time=0
        while kill -0 $SIR_PID > /dev/null 2>&1; do
            if [[ $wait_time -ge 30 ]]; then
                kill -TERM $SIR_PID || continue
                if [[ $reindex_attempts -ge 5 ]]; then
                    cat "$SIR_REINDEX_LOG_FILE"
                    exit 238
                else
                    continue 2
                fi
            fi
            sleep 1
            let 'wait_time = wait_time + 1'
        done

        break
    done

    echo `date` : Starting sir
    echo '==========' `date` '==========' >> "$SIR_LOG_FILE"
    python -m sir --debug amqp_watch >> "$SIR_LOG_FILE" 2>&1 &
    SIR_PID=$!
    disown
    echo "$SIR_PID" > "$SIR_PID_FILE"
    deactivate
    popd
fi

echo `date` : Pruning the cache
./admin/PruneCache
