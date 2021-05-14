#!/usr/bin/env bash

set -u

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

./admin/RunIncrementalJSONDump
