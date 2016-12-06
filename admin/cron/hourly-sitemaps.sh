#!/bin/bash -u

set -e

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

./admin/BuildIncrementalSitemaps.pl \
    --database READWRITE \
    --ping \
    --worker-count 7

./bin/rsync-sitemaps
