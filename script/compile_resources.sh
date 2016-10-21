#!/bin/sh

cd "$(dirname $0)/../"
./script/dbdefs_to_js.pl
node_modules/.bin/gulp $@
