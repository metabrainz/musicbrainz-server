#!/bin/bash -u

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

OUTPUT=`./admin/cron/slave.sh 2>&1` || echo "$OUTPUT"

OUTPUT=`
    ./admin/BuildIncrementalSitemaps.pl --ping --worker-count 7 2>&1
` || echo "$OUTPUT"

OUTPUT=`./bin/rsync-sitemaps` || echo "$OUTPUT"

# eof
