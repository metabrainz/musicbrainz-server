#!/usr/bin/env bash

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

X=${MIRROR_LOG:=$MB_SERVER_ROOT/mirror.log}
X=${LOGROTATE:=/usr/sbin/logrotate --state $MB_SERVER_ROOT/.logrotate-state}

./admin/replication/LoadReplicationChanges >> $MIRROR_LOG 2>&1 || {
    RC=$?
    echo `date`" : LoadReplicationChanges failed (rc=$RC) - see $MIRROR_LOG"
}

$LOGROTATE /dev/stdin <<EOF
$MIRROR_LOG {
    daily
    rotate 30
}
EOF

# eof
