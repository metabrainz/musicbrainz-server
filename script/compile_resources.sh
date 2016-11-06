#!/bin/bash

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

for task in "$@"; do
    if [ "$task" == "scripts" ]; then
        ./script/dbdefs_to_js.pl
        break
    fi
done

node_modules/.bin/gulp $@
