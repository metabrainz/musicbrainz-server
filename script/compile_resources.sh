#!/bin/bash

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)
cd "$MB_SERVER_ROOT"

./script/dbdefs_to_js.pl

./node_modules/.bin/gulp $@
