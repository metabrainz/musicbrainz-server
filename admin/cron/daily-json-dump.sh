#!/bin/bash -u

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

# Only do this on the nominated days (0=Sun 6=Sat)
if date +%w | grep -q [36]
then
    ./admin/RunJSONDump
fi
