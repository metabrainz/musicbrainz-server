#!/usr/bin/env bash

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

X=${SLAVE_LOG:=$MB_SERVER_ROOT/slave.log}
X=${LOGROTATE:=/usr/sbin/logrotate --state $MB_SERVER_ROOT/.logrotate-state}

./admin/replication/LoadReplicationChanges >> $SLAVE_LOG 2>&1 || {
    RC=$?
    echo `date`" : LoadReplicationChanges failed (rc=$RC) - see $SLAVE_LOG"
}

$LOGROTATE /dev/stdin <<EOF
$SLAVE_LOG {
    daily
    rotate 30
}
EOF

# eof
