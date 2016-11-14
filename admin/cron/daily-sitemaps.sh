#!/bin/bash -u

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

OUTPUT=`./admin/BuildSitemaps.pl --ping` || echo "$OUTPUT"

OUTPUT=`./bin/rsync-sitemaps` || echo "$OUTPUT"

# eof
