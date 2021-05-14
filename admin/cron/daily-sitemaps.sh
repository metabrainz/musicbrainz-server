#!/usr/bin/env bash

set -u
set -e

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

./admin/BuildSitemaps.pl --ping

./bin/rsync-sitemaps
