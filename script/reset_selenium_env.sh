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
SELECT pg_terminate_backend(pid)
  FROM pg_stat_activity
 WHERE usename = 'musicbrainz'
   AND query NOT LIKE '%pg_terminate_backend%';
SQL
    )
    OUTPUT=`echo "$CANCEL_QUERY" | ./admin/psql SELENIUM 2>&1` || ( echo "$OUTPUT" && exit 1 )
}

if [[ $SIR_DIR ]]; then
    # Stop sir to avoid deadlocks below.
    # TRUNCATE requires ACCESS EXCLUSIVE locks on each table.
    if [[ -f $SIR_PID_FILE ]]; then
        SIR_PID="$(cat "$SIR_PID_FILE")"
    fi

    if [[ $SIR_PID ]] && kill -0 "$SIR_PID" > /dev/null 2>&1; then
        echo `date` : Stopping sir
        kill -TERM "$SIR_PID"
        echo '' > "$SIR_PID_FILE"
    fi

    terminate_pg_backends

    # Temporarily drop sir triggers to avoid queueing thousands of
    # pending changes to the type tables via t/sql/initial.sql.
    echo `date` : Dropping sir triggers
    OUTPUT=`./admin/psql SELENIUM <"$SIR_DIR"/sql/DropTriggers.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

    echo `date` : Purging sir queues
    OUTPUT=`./script/purge_sir_queues.sh /sir-test 2>&1` || ( echo "$OUTPUT" && exit 1 )

    echo `date` : Purging Solr cores
    OUTPUT=`./script/purge_solr_cores.sh 2>&1` || ( echo "$OUTPUT" && exit 1 )
else
    terminate_pg_backends
fi

echo `date` : Truncating all tables
OUTPUT=`./admin/psql SELENIUM <./admin/sql/TruncateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql SELENIUM <./admin/sql/caa/TruncateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )
OUTPUT=`./admin/psql SELENIUM <./admin/sql/eaa/TruncateTables.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Inserting initial test data
OUTPUT=`./admin/psql SELENIUM < ./t/sql/initial.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Setting sequences
OUTPUT=`./admin/psql SELENIUM <./admin/sql/SetSequences.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

echo `date` : Inserting Selenium test data
OUTPUT=`./admin/psql SELENIUM < ./t/sql/selenium.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

if [[ -f $EXTRA_SQL ]]; then
    OUTPUT=`./admin/psql SELENIUM < "$EXTRA_SQL" 2>&1` || ( echo "$OUTPUT" && exit 1 )
fi

if [[ $SIR_DIR ]]; then
    echo `date` : Creating sir triggers
    OUTPUT=`./admin/psql SELENIUM <"$SIR_DIR"/sql/CreateTriggers.sql 2>&1` || ( echo "$OUTPUT" && exit 1 )

    cd "$SIR_DIR"
    . venv/bin/activate

    # Unfortunately, we must work around SOLR-109 for the time being by
    # detecting when the reindex command is stuck.
    reindex_attempts=0
    while true; do
        echo `date` : Reindexing search data
        python -m sir reindex > "$SIR_REINDEX_LOG_FILE" 2>&1 &
        SIR_PID=$!
        disown
        let 'reindex_attempts = reindex_attempts + 1'

        wait_time=0
        while kill -0 $SIR_PID > /dev/null 2>&1; do
            if [[ $wait_time -ge 10 ]]; then
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
    python -m sir amqp_watch > "$SIR_LOG_FILE" 2>&1 &
    SIR_PID=$!
    disown
    echo "$SIR_PID" > "$SIR_PID_FILE"
    deactivate
fi
