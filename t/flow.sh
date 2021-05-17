#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../"

echo '1..1'

OUTPUT=$(./node_modules/.bin/flow --quiet 2>&1)
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo 'ok 1 - Flow reported no errors!'
else
    echo 'not ok 1 - Flow reported errors!'
    echo "$(echo "$OUTPUT" | sed 's/^/# /')"
fi

./node_modules/.bin/flow stop > /dev/null 2>&1
exit $STATUS
