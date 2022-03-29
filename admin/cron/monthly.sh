#!/usr/bin/env bash

set -u

if [[ -t 1 ]]
then
    exec 2>&1 | ts '%X %Z'
fi

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

./admin/RunSampleDataDump

echo Monthly jobs complete!
