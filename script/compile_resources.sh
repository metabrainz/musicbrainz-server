#!/bin/sh

cd "$(dirname $0)/../"
eval "$(admin/ShowDBDefs)" && node_modules/.bin/gulp $@
