#!/bin/bash

# This script is simply used to recreate the test database after selenium
# tests run, as there's only a single 'prove' invocation.

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

echo '1..1'
./script/create_test_db.sh && echo 'ok 1 - test database created'
