#!/usr/bin/env bash

set -e -o pipefail -u

if [[ -t 1 ]]
then
    exec 2>&1 | ts '%X %Z'
fi

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

# Only do this on the nominated days 3=Wed and 6=Sat (for reference 0=Sun)
if date +%w | grep -qw '[36]'
then
    ./admin/RunSearchIndexesDump
fi
